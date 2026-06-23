import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/parser_utils.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AnalyticsService {
  List<SpendingBreakdownVM> parseSpendingBreakdownFromApi(List<dynamic> expensesByCategory) {
    return expensesByCategory.map((item) {
      final data = item as Map<String, dynamic>;
      return SpendingBreakdownVM(
        categoryId: data['categoryId']?.toString() ?? data['category_id']?.toString() ?? '',
        name: data['categoryName']?.toString() ?? 'Kategori Lainnya',
        emoji: data['emoji']?.toString() ?? '📦',
        colorHex: data['color']?.toString().replaceAll('#', '') ?? '81ECFF',
        amount: ParserUtils.toDouble(data['total']),
        percentage: ParserUtils.toDouble(data['percentage']),
        transactionCount: (data['transactionCount'] as num? ?? data['transaction_count'] as num? ?? 0).toInt(),
      );
    }).toList();
  }

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

  List<CategoryVM> parseCategoriesFromApi(List<dynamic> budgetComparison) {
    return budgetComparison.take(10).map((item) {
      final data = item as Map<String, dynamic>;
      final status = data['status']?.toString() ?? 'safe';
      final progress = ParserUtils.toDouble(data['percentageUsed'] ?? data['percentage_used']) / 100.0;
      final isOver = status == 'exceeded';
      
      String accentColorHex = data['color']?.toString().replaceAll('#', '') ?? '00C1D4';
      if (isOver) {
        accentColorHex = 'FF4B4B';
      } else if (status == 'warning') {
        accentColorHex = 'FFA500';
      }

      final spent = ParserUtils.toDouble(data['spent']);
      final budgetAmount = ParserUtils.toDouble(data['budget']);

      return CategoryVM(
        categoryId: data['categoryId']?.toString() ?? data['category_id']?.toString() ?? '',
        name: data['categoryName']?.toString() ?? 'Kategori Lainnya',
        amount: '${SavaioTheme.formatCurrency(spent)} dipakai',
        progress: progress.clamp(0.0, 1.0),
        limitText: budgetAmount > 0
            ? 'Anggaran: ${SavaioTheme.formatCurrency(budgetAmount)}'
            : 'Belum ada anggaran',
        statusText: isOver ? 'LEWAT BUDGET!' : '${(progress * 100).toStringAsFixed(0)}%',
        accentColorHex: accentColorHex,
        isOver: isOver,
        isBudgetExists: budgetAmount > 0,
        icon: data['emoji']?.toString() ?? '📦',
        rawCategoryName: data['categoryName']?.toString() ?? '',
        status: status == 'safe' ? 'active' : status,
      );
    }).toList();
  }

  List<TrendPoint> parseTrendFromApi(List<dynamic> monthlyTrend, {required bool isWeekly}) {
    if (monthlyTrend.isEmpty) return [];

    if (isWeekly) {
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      final mondayDay = now.day - (currentWeekday - 1);
      
      return List.generate(7, (index) {
        final targetDay = mondayDay + index;
        final dayIndex = targetDay - 1;
        
        double value = 0.0;
        if (dayIndex >= 0 && dayIndex < monthlyTrend.length) {
          value = ParserUtils.toDouble((monthlyTrend[dayIndex] as Map<String, dynamic>)['expense']);
        }
        return TrendPoint(index.toDouble(), value);
      }).toList();
    } else {
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

  HeroVM calculateHeroMetrics({
    required double totalSpent,
    required BudgetModel? allCategoryBudget,
    required List<double> dailyValues,
    required int daysInMonth,
    required String month,
  }) {
    final targetAmount = allCategoryBudget?.amount ?? 0.0;
    final dailyTarget = targetAmount > 0 ? targetAmount / daysInMonth : 0.0;

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

    final displayDailyValues = <double>[];
    for (int i = 0; i < dailyValues.length; i++) {
      if (dailyTarget > 0) {
        displayDailyValues.add(dailyValues[i] / dailyTarget);
      } else {
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

  List<CategoryVM> calculateCategoryBreakdown({
    required List<SpendingTargetItemVM> budgetTargets,
    required Map<String, double> realByCategory,
  }) {
    final sortedTargets = List<SpendingTargetItemVM>.from(budgetTargets);
    sortedTargets.sort((a, b) {
      if (a.isBudgetExists && !b.isBudgetExists) return -1;
      if (!a.isBudgetExists && b.isBudgetExists) return 1;
      return b.progress.compareTo(a.progress);
    });

    return sortedTargets.take(3).map((target) {
      final progress = target.progress;
      final isOver = target.isOver;

      String accentColorHex = '00C1D4';
      if (isOver) {
        accentColorHex = 'FF4B4B';
      } else if (target.status == 'warning') {
        accentColorHex = 'FFA500';
      } else if (!target.isBudgetExists) {
        accentColorHex = '6366F1';
      }

      return CategoryVM(
        categoryId: target.categoryId,
        name: target.categoryName,
        amount: '${SavaioTheme.formatCurrency(target.spent)} dipakai',
        progress: progress,
        limitText: target.isBudgetExists
            ? 'Anggaran: ${SavaioTheme.formatCurrency(target.target)}'
            : 'Belum ada anggaran',
        statusText: isOver ? 'LEWAT BUDGET!' : '${(progress * 100).toStringAsFixed(0)}%',
        accentColorHex: accentColorHex,
        isOver: isOver,
        isBudgetExists: target.isBudgetExists,
        icon: target.emoji ?? target.iconData ?? '📦',
        rawCategoryName: target.categoryName,
        status: target.status,
      );
    }).toList();
  }

  List<TrendPoint> calculateTrendPoints(List<double> dailyValues, {required bool isWeekly}) {
    if (dailyValues.isEmpty) return [];

    if (isWeekly) {
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      final mondayDay = now.day - (currentWeekday - 1);
      
      return List.generate(7, (index) {
        final targetDay = mondayDay + index;
        final dayIndex = targetDay - 1;
        
        double value = 0.0;
        if (dayIndex >= 0 && dayIndex < dailyValues.length) {
          value = dailyValues[dayIndex];
        }
        return TrendPoint(index.toDouble(), value);
      });
    } else {
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

  List<PieSegment> buildPieSegmentsFromCategories({
    required Map<String, double> byCategory,
    required double totalSpent,
  }) {
    if (totalSpent <= 0 || byCategory.isEmpty) return [];

    final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];

    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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

  AnalysisInsight? parseInsightFromApi(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AnalysisInsight(
      title: json['title']?.toString() ?? 'Rekomendasi Pintar',
      description: json['message']?.toString() ?? json['description']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
    );
  }

  AnalysisInsight generateInsight({
    required double totalSpent,
    required Map<String, double> byCategory,
    required List<SpendingTargetItemVM> budgetTargets,
  }) {
    if (totalSpent <= 0 || byCategory.isEmpty) {
      return AnalysisInsight(
        title: 'Rekomendasi Pintar',
        description: 'Belum cukup data transaksi untuk menyusun rekomendasi finansial.',
        buttonLabel: 'ANALISIS HEMAT',
        severity: 'info',
      );
    }

    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.first.key;
    final topAmount = sortedCategories.first.value;
    final topPercentage = (topAmount / totalSpent * 100).toStringAsFixed(0);

    final overBudgetCategories = budgetTargets
        .where((t) => t.isOver)
        .map((t) => t.categoryName)
        .toList();

    String description;
    String buttonLabel = 'ANALISIS HEMAT';
    String severity = 'info';

    if (overBudgetCategories.isNotEmpty) {
      description = 'Pos ${overBudgetCategories.first} melebihi budget! Konsumsi tertinggi ada di $topCategory ($topPercentage%).';
      buttonLabel = 'SESUAIKAN BUDGET';
      severity = 'danger';
    } else {
      final closeToBudget = budgetTargets.where((t) => t.progress > 0.8 && t.isBudgetExists).toList();
      if (closeToBudget.isNotEmpty) {
        description = '$topCategory menyerap $topPercentage% total pengeluaran. Waspada, pos ${closeToBudget.first.categoryName} sudah mendekati limit!';
        severity = 'warning';
      } else {
        description = 'Alokasi terbesar Anda berada di kategori $topCategory ($topPercentage%). Pertahankan performa keuangan sehat ini!';
      }
    }

    return AnalysisInsight(
      title: 'Rekomendasi Pintar',
      description: description,
      buttonLabel: buttonLabel,
      severity: severity,
    );
  }

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