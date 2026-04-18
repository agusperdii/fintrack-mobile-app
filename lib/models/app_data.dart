class AppData {
  final double balance;
  final List<Transaction> recentTransactions;
  final List<AnalysisData> analysis;
  final double? spendingTarget;
  final String? targetPeriod;

  AppData({
    required this.balance,
    required this.recentTransactions,
    required this.analysis,
    this.spendingTarget,
    this.targetPeriod,
  });

  // Dummy data generator
  static AppData getDummyData() {
    return AppData(
      balance: 15450000,
      spendingTarget: 5000000,
      targetPeriod: 'Bulanan',
      recentTransactions: [
        Transaction(title: 'Belanja Bulanan', amount: -500000, category: 'Food', date: '2026-04-10'),
        Transaction(title: 'Gaji Bulanan', amount: 10000000, category: 'Salary', date: '2026-04-01'),
        Transaction(title: 'Tagihan Listrik', amount: -250000, category: 'Bills', date: '2026-04-05'),
      ],
      analysis: [
        AnalysisData(label: 'Food', amount: 3000000, colorHex: 'FF4242'),
        AnalysisData(label: 'Transport', amount: 1500000, colorHex: '4285F4'),
        AnalysisData(label: 'Entertainment', amount: 1000000, colorHex: '34A853'),
      ],
    );
  }
}

class Transaction {
  final String title;
  final double amount;
  final String category;
  final String date;

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
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
