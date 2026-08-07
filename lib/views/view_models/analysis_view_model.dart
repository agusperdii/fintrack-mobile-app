// analysis_view_model.dart
// Kumpulan view model (VM) yang merepresentasikan data siap-tampil untuk halaman
// analisis (analysis page), seperti tren, breakdown kategori, dan insight.

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
  /// Nilai yang mungkin: info, warning, danger
  final String severity;

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
  /// Representasi warna dalam bentuk hex agar netral terhadap platform
  final String accentColorHex;
  final bool isOver;
  final bool isBudgetExists;
  final dynamic icon;
  final String rawCategoryName;
  /// Nilai yang mungkin: active, warning, exceeded
  final String status;

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
