import '../core/utils/parser_utils.dart';
import 'app_data.dart';

class BudgetModel {
  final String id;
  final double amount;
  final String periodType; // e.g., 'monthly'
  final String month;      // e.g., '2026-05'
  final String category;
  final SyncStatus syncStatus;

  String get categoryKey => ParserUtils.normalizeCategory(category);
  bool get isBudgetExists => id.isNotEmpty;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.periodType,
    required this.month,
    required this.category,
    this.syncStatus = SyncStatus.synced,
  });

  BudgetModel copyWith({
    String? id,
    double? amount,
    String? periodType,
    String? month,
    String? category,
    SyncStatus? syncStatus,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      periodType: periodType ?? this.periodType,
      month: month ?? this.month,
      category: category ?? this.category,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      amount: ParserUtils.toDouble(json['amount']),
      periodType: json['period_type']?.toString() ?? 'monthly',
      month: json['month']?.toString() ?? json['period']?.toString() ?? '',
      category: json['category']?.toString() ?? 'All',
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'period_type': periodType,
      'month': month,
      'category': category,
    };
  }
}
