class AnalysisCalculator {
  static double averageDailyExpense(double totalExpense) {
    return totalExpense / 30;
  }

  static double budgetPercentage(double target, double expense) {
    if (target <= 0) return 0;
    return (expense / target) * 100;
  }

  static bool isBelowBudget(double target, double expense) {
    return expense <= target;
  }

  static List<double> buildDailyValues(List<double> dailyExpenses, double dailyBudget) {
    if (dailyExpenses.isEmpty) return [];

    if (dailyBudget <= 0) {
      final maxVal = dailyExpenses.reduce((a, b) => a > b ? a : b);
      if (maxVal <= 0) return List.filled(dailyExpenses.length, 0.05);
      return dailyExpenses.map((e) => (e / maxVal).clamp(0.05, 1.0)).toList();
    }

    return dailyExpenses.map((expense) {
      final ratio = expense / dailyBudget;
      return ratio.clamp(0.05, 5.0);
    }).toList();
  }
}