import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/analysis_calculator.dart';
import 'package:savaio/core/utils/parser_utils.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AnalyticsService {
  /// Builds the high-level Hero metrics (Average, Budget %, Daily Values)
  HeroVM calculateHeroMetrics({
    required double totalSpent,
    required BudgetModel? allCategoryBudget,
    required List<double> weeklyPulseValues,
    required String month,
  }) {
    final targetAmount = allCategoryBudget?.amount ?? 0.0;
    
    // Accurate Daily Budget Calculation
    final daysInMonth = _getDaysInMonth(month);
    final dailyTarget = targetAmount / daysInMonth;
    
    double budgetPercentage = 0.0;
    bool isBelowBudget = true;

    if (allCategoryBudget != null && allCategoryBudget.isBudgetExists && targetAmount > 0) {
      budgetPercentage = AnalysisCalculator.budgetPercentage(targetAmount, totalSpent);
      isBelowBudget = AnalysisCalculator.isBelowBudget(targetAmount, totalSpent);
      
      if (isBelowBudget) {
        budgetPercentage = (100 - budgetPercentage).clamp(0, 100);
      } else {
        budgetPercentage = (budgetPercentage - 100).clamp(0, 500);
      }
    }

    final dailyExpenses = _normalizeWeeklyData(weeklyPulseValues);
    
    return HeroVM(
      averageAmount: AnalysisCalculator.averageDailyExpense(totalSpent),
      budgetPercentage: budgetPercentage,
      isBelowBudget: isBelowBudget,
      dailyValues: AnalysisCalculator.buildDailyValues(dailyExpenses, dailyTarget),
      dailyTarget: dailyTarget,
    );
  }

  /// Builds the detailed category breakdown items
  List<CategoryVM> calculateCategoryBreakdown({
    required List<SpendingTargetItemVM> budgetTargets,
  }) {
    // 1. Filter out 'All'
    final subCategories = budgetTargets
        .where((t) => ParserUtils.normalizeCategory(t.category) != 'all')
        .toList();
    
    // 2. Sort: Budget exists > Progress > Alphabetical
    subCategories.sort((a, b) {
      if (a.isBudgetExists && !b.isBudgetExists) return -1;
      if (!a.isBudgetExists && b.isBudgetExists) return 1;
      return b.progress.compareTo(a.progress);
    });

    // 3. Map to pure VM (Top 3)
    return subCategories.take(3).map((target) {
      final progress = target.progress;
      final isOver = target.isOver;

      // Color Hex logic (Platform neutral)
      String accentColorHex = '00C1D4'; // tertiary
      if (isOver) {
        accentColorHex = 'FF4B4B'; // error
      } else if (progress > 0.8) {
        accentColorHex = 'FFA500'; // warning
      } else if (!target.isBudgetExists) {
        accentColorHex = '6366F1'; // primary
      }

      return CategoryVM(
        name: target.category,
        amount: '${SavaioTheme.formatCurrency(target.spent)} terpakai',
        progress: progress,
        limitText: target.isBudgetExists 
            ? 'Target: ${SavaioTheme.formatCurrency(target.target)}' 
            : 'Target belum diatur',
        statusText: isOver ? 'OVER BUDGET!' : '${(progress * 100).toStringAsFixed(0)}%',
        accentColorHex: accentColorHex,
        isOver: isOver,
        isBudgetExists: target.isBudgetExists,
        icon: target.emoji ?? target.iconData,
        rawCategoryName: target.category,
      );
    }).toList();
  }

  /// Builds the trend points for the line chart
  List<TrendPoint> calculateTrendPoints(List<double> values) {
    return values.asMap().entries.map((e) {
      return TrendPoint(e.key.toDouble(), e.value / 100000);
    }).toList();
  }

  /// Builds the distribution segments for the pie chart
  List<PieSegment> calculatePieSegments(List<AnalysisData> rawAnalysis) {
    return rawAnalysis.map((item) {
      return PieSegment(
        value: item.amount,
        label: item.label,
        colorHex: item.colorHex,
      );
    }).toList();
  }

  /// Generates smart insights based on spending patterns
  AnalysisInsight generateInsight({
    required double totalSpent,
    required List<SpendingTargetItemVM> subCategories,
    required List<AnalysisData> rawAnalysis,
  }) {
    if (totalSpent <= 0) {
      return AnalysisInsight(
        title: 'Wawasan Pintar',
        description: 'Belum ada data pengeluaran yang cukup untuk memberikan wawasan.',
        buttonLabel: 'DETAIL PENGHEMATAN',
      );
    }

    final topCategory = rawAnalysis.isNotEmpty ? rawAnalysis.first.label : "Lainnya";
    
    return AnalysisInsight(
      title: 'Wawasan Pintar',
      description: 'Pengeluaran terbesar Anda adalah pada kategori $topCategory. Pastikan tetap sesuai budget!',
      buttonLabel: 'DETAIL PENGHEMATAN',
    );
  }

  // --- Helper Methods ---

  int _getDaysInMonth(String month) {
    try {
      final parts = month.split('-');
      if (parts.length != 2) return 30;
      final year = int.parse(parts[0]);
      final monthInt = int.parse(parts[1]);
      return DateTime(year, monthInt + 1, 0).day;
    } catch (_) {
      return 30;
    }
  }

  List<double> _normalizeWeeklyData(List<double> raw) {
    List<double> data = List.from(raw);
    while (data.length < 7) {
      data.add(0.0);
    }
    return data.take(7).toList();
  }
}
