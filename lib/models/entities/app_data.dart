import '../../core/utils/parser_utils.dart';

enum TransactionType { income, expense }

class AppData {
  final double initialBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;
  final List<AnalysisData> analysis;
  final double? spendingTarget;
  final String? targetPeriod;

  AppData({
    required this.initialBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
    required this.analysis,
    this.spendingTarget,
    this.targetPeriod,
  });

  double get balance => initialBalance + totalIncome - totalExpense;

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      initialBalance: ParserUtils.toDouble(json['initialBalance']),
      totalIncome: ParserUtils.toDouble(json['totalIncome']),
      totalExpense: ParserUtils.toDouble(json['totalExpense']),
      recentTransactions: (json['recentTransactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      analysis: (json['analysis'] as List)
          .map((a) => AnalysisData.fromJson(a))
          .toList(),
      spendingTarget: ParserUtils.toDouble(json['spendingTarget']),
      targetPeriod: json['targetPeriod'] as String?,
    );
  }


  // Dummy data generator
  static AppData getDummyData() {
    return AppData(
      initialBalance: 0,
      totalIncome: 10000000,
      totalExpense: 750000,
      spendingTarget: 5000000,
      targetPeriod: 'Bulanan',
      recentTransactions: [
        Transaction(
          title: 'Belanja Bulanan',
          amount: 500000,
          category: 'Food',
          date: '2026-04-10',
          type: TransactionType.expense,
        ),
        Transaction(
          title: 'Gaji Bulanan',
          amount: 10000000,
          category: 'Salary',
          date: '2026-04-01',
          type: TransactionType.income,
        ),
        Transaction(
          title: 'Tagihan Listrik',
          amount: 250000,
          category: 'Bills',
          date: '2026-04-05',
          type: TransactionType.expense,
        ),
      ],
      analysis: [
        AnalysisData(label: 'Food', amount: 3000000, colorHex: 'FF4242'),
        AnalysisData(label: 'Transport', amount: 1500000, colorHex: '4285F4'),
        AnalysisData(
          label: 'Entertainment',
          amount: 1000000,
          colorHex: '34A853',
        ),
      ],
    );
  }
}

class Transaction {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final TransactionType type;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String rawDate = json['date']?.toString() ?? '';
    // Handle both ISO format and YYYY-MM-DD
    String dateStr = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
    
    return Transaction(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? json['description']?.toString() ?? 'Transaksi',
      amount: ParserUtils.toDouble(json['amount']),
      category: json['category']?.toString() ?? 'Lainnya',
      date: dateStr,
      type: json['type']?.toString() == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}

class AnalysisData {
  final String label;
  final double amount;
  final String colorHex;

  AnalysisData({
    required this.label,
    required this.amount,
    required this.colorHex,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      label: json['label'] as String,
      amount: ParserUtils.toDouble(json['amount']),
      colorHex: json['colorHex'] as String,
    );
  }
}
