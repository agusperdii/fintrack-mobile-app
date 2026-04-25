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
      initialBalance: (json['initialBalance'] ?? 0.0).toDouble(),
      totalIncome: (json['totalIncome'] ?? 0.0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0.0).toDouble(),
      recentTransactions: (json['recentTransactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      analysis: (json['analysis'] as List)
          .map((a) => AnalysisData.fromJson(a))
          .toList(),
      spendingTarget: (json['spendingTarget'] ?? 0.0).toDouble(),
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
  final String title;
  final double amount;
  final String category;
  final String date;
  final TransactionType type;

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      title: json['title'] as String,
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'] as String,
      date: json['date'] as String,
      type: json['type'] == 'income'
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
      amount: (json['amount'] ?? 0.0).toDouble(),
      colorHex: json['colorHex'] as String,
    );
  }
}
