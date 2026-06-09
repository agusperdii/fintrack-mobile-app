import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/parser_utils.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AnalyticsService {
  /// Builds the spending breakdown items from API expenses by category
  List<SpendingBreakdownVM> parseSpendingBreakdownFromApi(List<dynamic> expensesByCategory) {
    return expensesByCategory.map((item) {
      final data = item as Map<String, dynamic>;
      return SpendingBreakdownVM(
        categoryId: data['categoryId']?.toString() ?? data['category_id']?.toString() ?? '',
        name: data['categoryName']?.toString() ?? 'Kategori',
        emoji: data['emoji']?.toString() ?? '📦',
        colorHex: data['color']?.toString().replaceAll('#', '') ?? '81ECFF',
        amount: ParserUtils.toDouble(data['total']),
        percentage: ParserUtils.toDouble(data['percentage']),
        transactionCount: (data['transactionCount'] as num? ?? data['transaction_count'] as num? ?? 0).toInt(),
      );
    }).toList();
  }

  /// Builds the high-level Hero metrics (Average, Budget %, Daily Values) from API data
  HeroVM parseHeroFromApi({
    required Map<String, dynamic> summary,
    required Map<String, dynamic> period,
    required List<dynamic> monthlyTrend,
    required BudgetModel? allCategoryBudget,
  }) {
    final totalExpense = ParserUtils.toDouble(summary['totalExpense'] ?? summary['total_expense']);
    final startDate = DateTime.tryParse(period['startDate']?.toString() ?? '') ?? DateTime.now();
    final endDate = DateTime.tryParse(period['endDate']?.toString() ?? '') ?? DateTime.now();
    final daysCount = endDate.difference(startDate).inDays + 1;
    
    final averageAmount = daysCount > 0 ? totalExpense / daysCount : totalExpense / 30;

    final targetAmount = allCategoryBudget?.amount ?? 0.0;
    final dailyTarget = targetAmount > 0 ? targetAmount / (daysCount > 0 ? daysCount : 30) : 0.0;

    // Calculate budget percentage (overall)
    double budgetPercentage = 0.0;
    bool isBelowBudget = true;

    if (targetAmount > 0) {
      budgetPercentage = (totalExpense / targetAmount) * 100;
      isBelowBudget = totalExpense <= targetAmount;

      if (isBelowBudget) {
        budgetPercentage = (100 - budgetPercentage).clamp(0, 100);
      } else {
        budgetPercentage = (budgetPercentage - 100).clamp(0, 500);
      }
    }

    // Daily values from trend for the mini-chart in Hero card
    final displayDailyValues = monthlyTrend.map((e) {
      final expense = ParserUtils.toDouble((e as Map<String, dynamic>)['expense']);
      if (dailyTarget > 0) return expense / dailyTarget;
      return expense;
    }).toList();

    return HeroVM(
      averageAmount: averageAmount,
      budgetPercentage: budgetPercentage,
      isBelowBudget: isBelowBudget,
      dailyValues: displayDailyValues,
      dailyTarget: dailyTarget,
    );
  }

  /// Builds the detailed category breakdown items from API budget comparison
  List<CategoryVM> parseCategoriesFromApi(List<dynamic> budgetComparison) {
    return budgetComparison.take(10).map((item) {
      final data = item as Map<String, dynamic>;
      final status = data['status']?.toString() ?? 'safe';
      final progress = ParserUtils.toDouble(data['percentageUsed'] ?? data['percentage_used']) / 100.0;
      final isOver = status == 'exceeded';
      
      String accentColorHex = data['color']?.toString().replaceAll('#', '') ?? '00C1D4';
      if (isOver) {
        accentColorHex = 'FF4B4B'; // force error color if exceeded
      } else if (status == 'warning') {
        accentColorHex = 'FFA500'; // force warning color
      }

      final spent = ParserUtils.toDouble(data['spent']);
      final budgetAmount = ParserUtils.toDouble(data['budget']);

      return CategoryVM(
        categoryId: data['categoryId']?.toString() ?? data['category_id']?.toString() ?? '',
        name: data['categoryName']?.toString() ?? 'Kategori',
        amount: '${SavaioTheme.formatCurrency(spent)} terpakai',
        progress: progress.clamp(0.0, 1.0),
        limitText: budgetAmount > 0
            ? 'Target: ${SavaioTheme.formatCurrency(budgetAmount)}'
            : 'Target belum diatur',
        statusText: isOver ? 'OVER BUDGET!' : '${(progress * 100).toStringAsFixed(0)}%',
        accentColorHex: accentColorHex,
        isOver: isOver,
        isBudgetExists: budgetAmount > 0,
        icon: data['emoji']?.toString() ?? '📦',
        rawCategoryName: data['categoryName']?.toString() ?? '',
        status: status == 'safe' ? 'active' : status,
      );
    }).toList();
  }

  /// Builds the trend points from API monthly trend
  List<TrendPoint> parseTrendFromApi(List<dynamic> monthlyTrend, {required bool isWeekly}) {
    if (monthlyTrend.isEmpty) return [];

    if (isWeekly) {
      // Weekly mode: show this week (Monday to Sunday)
      final now = DateTime.now();
      final currentWeekday = now.weekday; // 1 = Mon, ..., 7 = Sun
      
      // Calculate the day of the month for Monday of this week
      final mondayDay = now.day - (currentWeekday - 1);
      
      return List.generate(7, (index) {
        final targetDay = mondayDay + index; // 1-based day of month
        final dayIndex = targetDay - 1; // 0-based index for monthlyTrend
        
        double value = 0.0;
        if (dayIndex >= 0 && dayIndex < monthlyTrend.length) {
          value = ParserUtils.toDouble((monthlyTrend[dayIndex] as Map<String, dynamic>)['expense']);
        }
        return TrendPoint(index.toDouble(), value);
      }).toList();
    } else {
      // Aggregate by 4 groups (weeks approx) if data is long, or just return all
      if (monthlyTrend.length > 14) {
        final aggregated = <double>[];
        int groupSize = (monthlyTrend.length / 4).ceil();
        for (int i = 0; i < 4; i++) {
          double sum = 0;
          for (int j = 0; j < groupSize && (i * groupSize + j) < monthlyTrend.length; j++) {
            sum += ParserUtils.toDouble((monthlyTrend[i * groupSize + j] as Map<String, dynamic>)['expense']);
          }
          aggregated.add(sum);
        }
        return aggregated.asMap().entries.map((e) => TrendPoint(e.key.toDouble(), e.value)).toList();
      }
      
      return monthlyTrend.asMap().entries.map((e) {
        final val = ParserUtils.toDouble((e.value as Map<String, dynamic>)['expense']);
        return TrendPoint(e.key.toDouble(), val);
      }).toList();
    }
  }

  /// Builds pie segments from API expenses by category
  List<PieSegment> parsePieFromApi(List<dynamic> expensesByCategory) {
    return expensesByCategory.map((item) {
      final data = item as Map<String, dynamic>;
      return PieSegment(
        value: ParserUtils.toDouble(data['total']),
        label: data['categoryName']?.toString() ?? '',
        colorHex: data['color']?.toString().replaceAll('#', '') ?? '81ECFF',
      );
    }).toList();
  }

  /// Builds the high-level Hero metrics (Average, Budget %, Daily Values) (LOCAL FALLBACK)
  HeroVM calculateHeroMetrics({
    required double totalSpent,
    required BudgetModel? allCategoryBudget,
    required List<double> dailyValues,
    required int daysInMonth,
    required String month,
  }) {
    final targetAmount = allCategoryBudget?.amount ?? 0.0;
    final dailyTarget = targetAmount > 0 ? targetAmount / daysInMonth : 0.0;

    // Calculate budget percentage
    double budgetPercentage = 0.0;
    bool isBelowBudget = true;

    if (allCategoryBudget != null && targetAmount > 0) {
      budgetPercentage = (totalSpent / targetAmount) * 100;
      isBelowBudget = totalSpent <= targetAmount;

      if (isBelowBudget) {
        budgetPercentage = (100 - budgetPercentage).clamp(0, 100);
      } else {
        budgetPercentage = (budgetPercentage - 100).clamp(0, 500);
      }
    }

    // For daily values, use actual values if no budget target, or ratio if budget exists
    final displayDailyValues = <double>[];
    for (int i = 0; i < dailyValues.length; i++) {
      if (dailyTarget > 0) {
        // Ratio to daily target
        displayDailyValues.add(dailyValues[i] / dailyTarget);
      } else {
        // Direct value (will be scaled by chart)
        displayDailyValues.add(dailyValues[i]);
      }
    }

    return HeroVM(
      averageAmount: daysInMonth > 0 ? totalSpent / daysInMonth : totalSpent / 30,
      budgetPercentage: budgetPercentage,
      isBelowBudget: isBelowBudget,
      dailyValues: displayDailyValues,
      dailyTarget: dailyTarget,
    );
  }

  /// Builds the detailed category breakdown items from real transaction data (LOCAL FALLBACK)
  List<CategoryVM> calculateCategoryBreakdown({
    required List<SpendingTargetItemVM> budgetTargets,
    required Map<String, double> realByCategory,
  }) {
    // Sort: Budget exists > Progress > Alphabetical
    final sortedTargets = List<SpendingTargetItemVM>.from(budgetTargets);
    sortedTargets.sort((a, b) {
      if (a.isBudgetExists && !b.isBudgetExists) return -1;
      if (!a.isBudgetExists && b.isBudgetExists) return 1;
      return b.progress.compareTo(a.progress);
    });

    // 3. Map to pure VM (Top 3)
    return sortedTargets.take(3).map((target) {
      final progress = target.progress;
      final isOver = target.isOver;

      // Color Hex logic based on budget status
      String accentColorHex = '00C1D4'; // tertiary
      if (isOver) {
        accentColorHex = 'FF4B4B'; // error
      } else if (target.status == 'warning') {
        accentColorHex = 'FFA500'; // warning
      } else if (!target.isBudgetExists) {
        accentColorHex = '6366F1'; // primary
      }

      return CategoryVM(
        categoryId: target.categoryId,
        name: target.categoryName,
        amount: '${SavaioTheme.formatCurrency(target.spent)} terpakai',
        progress: progress,
        limitText: target.isBudgetExists
            ? 'Target: ${SavaioTheme.formatCurrency(target.target)}'
            : 'Target belum diatur',
        statusText: isOver ? 'OVER BUDGET!' : '${(progress * 100).toStringAsFixed(0)}%',
        accentColorHex: accentColorHex,
        isOver: isOver,
        isBudgetExists: target.isBudgetExists,
        icon: target.emoji ?? target.iconData ?? '📦',
        rawCategoryName: target.categoryName,
        status: target.status,
      );
    }).toList();
  }

  /// Builds the trend points for the line chart from daily values
  /// isWeekly: true = this week (Monday to Sunday), false = weekly aggregation for the month
  List<TrendPoint> calculateTrendPoints(List<double> dailyValues, {required bool isWeekly}) {
    if (dailyValues.isEmpty) return [];

    if (isWeekly) {
      // Weekly mode: show this week (Monday to Sunday)
      final now = DateTime.now();
      final currentWeekday = now.weekday; // 1 = Mon, ..., 7 = Sun
      
      // Calculate the day of the month for Monday of this week
      final mondayDay = now.day - (currentWeekday - 1);
      
      return List.generate(7, (index) {
        final targetDay = mondayDay + index; // 1-based day of month
        final dayIndex = targetDay - 1; // 0-based index for dailyValues
        
        double value = 0.0;
        if (dayIndex >= 0 && dayIndex < dailyValues.length) {
          value = dailyValues[dayIndex];
        }
        return TrendPoint(index.toDouble(), value);
      });
    } else {
      // Monthly mode: aggregate by week (4 weeks)
      final weeklyAggregated = <double>[];
      for (int i = 0; i < 4; i++) {
        double weekTotal = 0.0;
        for (int j = 0; j < 7 && (i * 7 + j) < dailyValues.length; j++) {
          weekTotal += dailyValues[i * 7 + j];
        }
        weeklyAggregated.add(weekTotal);
      }
      return weeklyAggregated.asMap().entries.map((e) {
        return TrendPoint(e.key.toDouble(), e.value);
      }).toList();
    }
  }

  /// Builds pie segments from real category breakdown
  List<PieSegment> buildPieSegmentsFromCategories({
    required Map<String, double> byCategory,
    required double totalSpent,
  }) {
    if (totalSpent <= 0 || byCategory.isEmpty) return [];

    // Predefined colors for categories
    final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];

    // Sort by amount descending
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Map to PieSegment with colors
    return sortedCategories.asMap().entries.map((entry) {
      final idx = entry.key;
      final category = entry.value;
      return PieSegment(
        value: category.value,
        label: category.key,
        colorHex: colors[idx % colors.length],
      );
    }).toList();
  }

  /// Parses insight from API data
  AnalysisInsight? parseInsightFromApi(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AnalysisInsight(
      title: json['title']?.toString() ?? 'Wawasan Pintar',
      description: json['message']?.toString() ?? json['description']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
    );
  }

  /// Generates smart insights based on actual spending patterns (fallback)
  AnalysisInsight generateInsight({
    required double totalSpent,
    required Map<String, double> byCategory,
    required List<SpendingTargetItemVM> budgetTargets,
  }) {
    if (totalSpent <= 0 || byCategory.isEmpty) {
      return AnalysisInsight(
        title: 'Wawasan Pintar',
        description: 'Belum ada data pengeluaran yang cukup untuk memberikan wawasan.',
        buttonLabel: 'DETAIL PENGHEMATAN',
        severity: 'info',
      );
    }

    // Find top category
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.first.key;
    final topAmount = sortedCategories.first.value;
    final topPercentage = (topAmount / totalSpent * 100).toStringAsFixed(0);

    // Check for over-budget categories
    final overBudgetCategories = budgetTargets
        .where((t) => t.isOver)
        .map((t) => t.categoryName)
        .toList();

    String description;
    String buttonLabel = 'DETAIL PENGHEMATAN';
    String severity = 'info';

    if (overBudgetCategories.isNotEmpty) {
      description = 'Kategori ${overBudgetCategories.first} melebihi budget! Pengeluaran terbesar pada $topCategory ($topPercentage%).';
      buttonLabel = 'ATUR BUDGET';
      severity = 'danger';
    } else {
      // Check if close to budget (80%+)
      final closeToBudget = budgetTargets.where((t) => t.progress > 0.8 && t.isBudgetExists).toList();
      if (closeToBudget.isNotEmpty) {
        description = '$topCategory menghabiskan $topPercentage% dari total pengeluaran. Hati-hati, kategori ${closeToBudget.first.categoryName} sudah hampir melebihi budget!';
        severity = 'warning';
      } else {
        description = 'Pengeluaran terbesar Anda adalah pada kategori $topCategory ($topPercentage%). Pertahankan pengelolaan keuangan yang baik!';
      }
    }

    return AnalysisInsight(
      title: 'Wawasan Pintar',
      description: description,
      buttonLabel: buttonLabel,
      severity: severity,
    );
  }

  // --- Legacy methods kept for backwards compatibility ---

  /// Builds the distribution segments for the pie chart (legacy)
  List<PieSegment> calculatePieSegments(List<AnalysisData> rawAnalysis) {
    return rawAnalysis.map((item) {
      return PieSegment(
        value: item.amount,
        label: item.label,
        colorHex: item.colorHex,
      );
    }).toList();
  }
}
