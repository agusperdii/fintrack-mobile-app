class TrendPoint {
  final double x;
  final double y;

  TrendPoint(this.x, this.y);
}

class PieSegment {
  final double value;
  final String label;
  final String colorHex;

  PieSegment({
    required this.value,
    required this.label,
    required this.colorHex,
  });
}

class AnalysisInsight {
  final String title;
  final String description;
  final String? buttonLabel;
  final String severity; // info, warning, danger

  AnalysisInsight({
    required this.title,
    required this.description,
    this.buttonLabel,
    this.severity = 'info',
  });
}

class SpendingBreakdownVM {
  final String categoryId;
  final String name;
  final String emoji;
  final String colorHex;
  final double amount;
  final double percentage;
  final int transactionCount;

  SpendingBreakdownVM({
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class AnalysisPageVM {
  final HeroVM hero;
  final List<CategoryVM> categories;
  final List<SpendingBreakdownVM> spendingBreakdown;
  final AnalysisInsight insight;
  final List<TrendPoint> trendPoints;
  final List<PieSegment> pieSegments;
  final bool isWeekly;
  final bool hasData;

  AnalysisPageVM({
    required this.hero,
    required this.categories,
    required this.spendingBreakdown,
    required this.insight,
    required this.trendPoints,
    required this.pieSegments,
    required this.isWeekly,
    required this.hasData,
  });
}

class HeroVM {
  final double averageAmount;
  final double budgetPercentage;
  final bool isBelowBudget;
  final List<double> dailyValues;
  final double dailyTarget;

  HeroVM({
    required this.averageAmount,
    required this.budgetPercentage,
    required this.isBelowBudget,
    required this.dailyValues,
    required this.dailyTarget,
  });
}

class CategoryVM {
  final String categoryId;
  final String name;
  final String amount;
  final double progress;
  final String limitText;
  final String statusText;
  final String accentColorHex; // Platform-neutral color representation
  final bool isOver;
  final bool isBudgetExists;
  final dynamic icon; 
  final String rawCategoryName;
  final String status; // active, warning, exceeded

  CategoryVM({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.progress,
    required this.limitText,
    required this.statusText,
    required this.accentColorHex,
    required this.isOver,
    required this.isBudgetExists,
    required this.icon,
    required this.rawCategoryName,
    this.status = 'active',
  });
}
