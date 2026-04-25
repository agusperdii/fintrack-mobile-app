enum TransactionType { income, expense }

class AppData {
  final double initialBalance;
  final List<Transaction> recentTransactions;
  final List<AnalysisData> analysis;
  final double? spendingTarget;
  final String? targetPeriod;

  AppData({
    required this.initialBalance,
    required this.recentTransactions,
    required this.analysis,
    this.spendingTarget,
    this.targetPeriod,
  });

  double get totalIncome => recentTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => recentTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => initialBalance + totalIncome - totalExpense;

  // Dummy data generator
  static AppData getDummyData() {
    return AppData(
      initialBalance: 0,
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
}
