// monthly_summary_model.dart
// Model data untuk ringkasan keuangan bulanan dan tahunan pengguna,
// termasuk drill-down transaksi per bulan dan data paginasi.

import '../core/utils/parser_utils.dart';
import 'app_data.dart';

class MonthlySummaryModel {
  /// Format YYYY-MM
  final String month;
  /// Contoh format: "May 2026"
  final String label;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double netCashflow;
  final double savingRate;
  final int transactionCount;
  final int incomeTransactionCount;
  final int expenseTransactionCount;
  final TopCategory? topCategory;
  final bool hasTransactions;

  MonthlySummaryModel({
    required this.month,
    required this.label,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.netCashflow,
    required this.savingRate,
    required this.transactionCount,
    required this.incomeTransactionCount,
    required this.expenseTransactionCount,
    this.topCategory,
    required this.hasTransactions,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      month: json['month']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      totalIncome: ParserUtils.toDouble(json['totalIncome'] ?? json['total_income'] ?? 0),
      totalExpense: ParserUtils.toDouble(json['totalExpense'] ?? json['total_expense'] ?? 0),
      totalSavings: ParserUtils.toDouble(json['totalSavings'] ?? json['total_savings'] ?? 0),
      netCashflow: ParserUtils.toDouble(json['netCashflow'] ?? json['net_cashflow'] ?? 0),
      savingRate: ParserUtils.toDouble(json['savingRate'] ?? json['saving_rate'] ?? 0),
      transactionCount: (json['transactionCount'] as num? ??
              json['transaction_count'] as num? ??
              0)
          .toInt(),
      incomeTransactionCount: (json['incomeTransactionCount'] as num? ??
              json['income_transaction_count'] as num? ??
              0)
          .toInt(),
      expenseTransactionCount: (json['expenseTransactionCount'] as num? ??
              json['expense_transaction_count'] as num? ??
              0)
          .toInt(),
      topCategory: json['topCategory'] != null || json['top_category'] != null
          ? TopCategory.fromJson(
              (json['topCategory'] ?? json['top_category']) as Map<String, dynamic>)
          : null,
      hasTransactions: json['hasTransactions'] == true ||
          json['has_transactions'] == true,
    );
  }
}

class TopCategory {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final double total;
  final double percentage;

  TopCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.total,
    required this.percentage,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    return TopCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '📦',
      color: json['color']?.toString() ?? '#81ECFF',
      total: ParserUtils.toDouble(json['total']),
      percentage: ParserUtils.toDouble(json['percentage']),
    );
  }
}

/// Response ringkasan lengkap dari GET /summary?year=YYYY
class YearSummary {
  final int year;
  final String currency;
  final List<MonthlySummaryModel> months;

  YearSummary({
    required this.year,
    required this.currency,
    required this.months,
  });

  factory YearSummary.fromJson(Map<String, dynamic> json) {
    return YearSummary(
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      currency: json['currency']?.toString() ?? 'IDR',
      months: (json['months'] as List? ?? [])
          .map((m) => MonthlySummaryModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Drill-down bulan dari GET /summary/{month}/transactions
class MonthTransactions {
  final String month;
  final String label;
  final String currency;
  final MonthSummary summary;
  final List<Transaction> transactions;
  final Pagination pagination;

  MonthTransactions({
    required this.month,
    required this.label,
    required this.currency,
    required this.summary,
    required this.transactions,
    required this.pagination,
  });

  factory MonthTransactions.fromJson(Map<String, dynamic> json) {
    return MonthTransactions(
      month: json['month']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'IDR',
      summary: MonthSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MonthSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double netCashflow;
  final int transactionCount;

  MonthSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.netCashflow,
    required this.transactionCount,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> json) {
    return MonthSummary(
      totalIncome: ParserUtils.toDouble(json['totalIncome'] ?? json['total_income'] ?? 0),
      totalExpense: ParserUtils.toDouble(json['totalExpense'] ?? json['total_expense'] ?? 0),
      totalSavings: ParserUtils.toDouble(json['totalSavings'] ?? json['total_savings'] ?? 0),
      netCashflow: ParserUtils.toDouble(json['netCashflow'] ?? json['net_cashflow'] ?? 0),
      transactionCount: (json['transactionCount'] as num? ??
              json['transaction_count'] as num? ??
              0)
          .toInt(),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num? ??
              json['total_pages'] as num? ??
              0)
          .toInt(),
    );
  }

  bool get hasMore => page < totalPages;
}