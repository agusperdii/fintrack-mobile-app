class AnalysisCalculator {
  static double averageDailyExpense(double totalExpense) {
    // Basic monthly average
    return totalExpense / 30;
  }

  static double budgetPercentage(double target, double expense) {
    if (target <= 0) return 0;
    // Percentage used: (expense / target) * 100
    return (expense / target) * 100;
  }

  static bool isBelowBudget(double target, double expense) {
    return expense <= target;
  }

  static List<double> buildDailyValues(List<double> dailyExpenses, double dailyBudget) {
    if (dailyBudget <= 0) return List.filled(7, 0);

    return dailyExpenses.map((expense) {
      // Return ratio (e.g., 0.5 for 50%, 1.2 for 120%)
      return expense / dailyBudget;
    }).toList();
  }
}