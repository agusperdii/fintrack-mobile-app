import '../core/utils/parser_utils.dart';

class MonthlySummaryModel {
  final String month;
  final double income;
  final double expense;
  final int transactionCount;

  MonthlySummaryModel({
    required this.month,
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      month: json['month'] ?? '',
      income: ParserUtils.toDouble(json['income'] ?? json['total_income']),
      expense: ParserUtils.toDouble(json['expense'] ?? json['total_expense']),
      transactionCount: json['count'] as int? ?? json['transaction_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'income': income,
      'expense': expense,
      'count': transactionCount,
    };
  }
}
