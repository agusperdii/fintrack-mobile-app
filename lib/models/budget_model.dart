// budget_model.dart
// Model data untuk merepresentasikan anggaran (budget) bulanan pengguna,
// termasuk konversi ke/dari JSON untuk komunikasi dengan API.

import '../core/utils/parser_utils.dart';
import 'app_data.dart';

class BudgetModel {
  final String id;
  final String? userId;
  final String? categoryId;
  final double amount;
  /// Format YYYY-MM
  final String startMonth;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;
  final SyncStatus syncStatus;

  BudgetModel({
    required this.id,
    this.userId,
    this.categoryId,
    required this.amount,
    required this.startMonth,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.syncStatus = SyncStatus.synced,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      amount: ParserUtils.toDouble(json['amount']),
      startMonth: json['start_month']?.toString() ?? json['month']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      syncStatus: SyncStatus.synced,
    );
  }

  /// Untuk request upsert POST /budgets
  Map<String, dynamic> toRequestJson() => {
        'category_id': categoryId,
        'amount': amount,
        'start_month': startMonth,
      };

  /// Untuk request PATCH /budgets/{id}
  Map<String, dynamic> toPatchJson() => {
        if (amount > 0) 'amount': amount,
        'start_month': startMonth,
      };

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    String? startMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
    SyncStatus? syncStatus,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      startMonth: startMonth ?? this.startMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// Response status budget dari GET /budgets/status
class BudgetStatusVM {
  final String id;
  final String categoryId;
  final double amount;
  final String startMonth;
  final Category? category;
  final double spent;
  final double remaining;
  final double percentageUsed;
  /// Status: 'active', 'warning', atau 'exceeded'
  final String status;

  BudgetStatusVM({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.startMonth,
    this.category,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.status,
  });

  factory BudgetStatusVM.fromJson(Map<String, dynamic> json) {
    return BudgetStatusVM(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      amount: ParserUtils.toDouble(json['amount']),
      startMonth: json['start_month']?.toString() ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      spent: ParserUtils.toDouble(json['spent']),
      remaining: ParserUtils.toDouble(json['remaining']),
      percentageUsed: ParserUtils.toDouble(json['percentage_used']),
      status: json['status']?.toString() ?? 'active',
    );
  }
}