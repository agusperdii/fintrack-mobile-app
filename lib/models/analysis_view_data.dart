import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/models/app_data.dart';

class AnalysisViewData {
  final List<AnalysisCategoryData> categoryBreakdown;
  final List<double> dailyTrend;
  final double totalExpense;
  final double targetAmount;
  final double averageAmount;
  final double budgetPercentage;
  final bool isBelowBudget;

  const AnalysisViewData({
    required this.categoryBreakdown,
    required this.dailyTrend,
    required this.totalExpense,
    required this.targetAmount,
    required this.averageAmount,
    required this.budgetPercentage,
    required this.isBelowBudget,
  });

  factory AnalysisViewData.fromMap(Map<String, dynamic> data) {
    final rawBreakdown = data['category_breakdown'] as List<dynamic>? ?? [];
    
    final categoryBreakdown = rawBreakdown.map((e) {
      final map = e as Map<String, dynamic>;
      final amount = (map['amount'] as num?)?.toDouble() ?? 0.0;
      final limit = (map['budget_limit'] as num?)?.toDouble() ?? 0.0;
      
      return AnalysisCategoryData(
        label: map['label'] as String? ?? 'Lainnya',
        amount: amount,
        colorHex: map['color'] as String? ?? '9E9E9E',
        budgetLimit: limit,
        progress: limit > 0 ? (amount / limit).clamp(0.0, 1.0) : 0.0,
        status: limit == 0 ? 'Stabil' : (amount > limit ? 'Over' : 'Aman'),
      );
    }).toList();

    final dailyTrend = (data['daily_trend'] as List<dynamic>? ?? []).map((e) => (e as num).toDouble()).toList();
    final totalExpense = (data['total_expense'] as num?)?.toDouble() ?? 0.0;
    final targetAmount = (data['target_amount'] as num?)?.toDouble() ?? 0.0;
    final averageAmount = (data['average_daily_expense'] as num?)?.toDouble() ?? 0.0;

    return AnalysisViewData(
      categoryBreakdown: categoryBreakdown,
      dailyTrend: dailyTrend,
      totalExpense: totalExpense,
      targetAmount: targetAmount,
      averageAmount: averageAmount,
      budgetPercentage: targetAmount > 0 ? (totalExpense / targetAmount) * 100 : 0.0,
      isBelowBudget: totalExpense <= targetAmount || targetAmount == 0,
    );
  }

  // Chart Helpers
  List<FlSpot> getTrendSpots(bool isWeekly) {
    final dailySpots = dailyTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    return isWeekly ? dailySpots.take(7).toList() : dailySpots;
  }

  List<String> getTrendDays(bool isWeekly) {
    return isWeekly 
        ? const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN']
        : List.generate(dailyTrend.length, (i) => (i + 1).toString());
  }

  // Helper for empty state
  static AnalysisViewData empty() => const AnalysisViewData(
    categoryBreakdown: [],
    dailyTrend: [0, 0, 0, 0, 0, 0, 0],
    totalExpense: 0,
    targetAmount: 0,
    averageAmount: 0,
    budgetPercentage: 0,
    isBelowBudget: true,
  );
}

class AnalysisCategoryData {
  final String label;
  final double amount;
  final String colorHex;
  final double budgetLimit;
  final double progress;
  final String status;

  const AnalysisCategoryData({
    required this.label,
    required this.amount,
    required this.colorHex,
    required this.budgetLimit,
    required this.progress,
    required this.status,
  });

  // Convert to legacy AnalysisData if needed
  AnalysisData toAnalysisData() => AnalysisData(
    label: label,
    amount: amount,
    colorHex: colorHex,
  );
}
