import '../../core/utils/parser_utils.dart';

enum TransactionType { income, expense }
enum SyncStatus { idle, pending, syncing, synced, failed }

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

  AppData copyWith({
    double? initialBalance,
    double? totalIncome,
    double? totalExpense,
    List<Transaction>? recentTransactions,
    List<AnalysisData>? analysis,
    double? spendingTarget,
    String? targetPeriod,
  }) {
    return AppData(
      initialBalance: initialBalance ?? this.initialBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      analysis: analysis ?? this.analysis,
      spendingTarget: spendingTarget ?? this.spendingTarget,
      targetPeriod: targetPeriod ?? this.targetPeriod,
    );
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final analysisRaw = json['analysis'] ?? json['category_breakdown'];
    final List<AnalysisData> parsedAnalysis;

    if (analysisRaw is List) {
      parsedAnalysis = analysisRaw.map((a) => AnalysisData.fromJson(a)).toList();
    } else if (analysisRaw is Map) {
      final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];
      int i = 0;
      parsedAnalysis = analysisRaw.entries.map((e) {
        final color = colors[i % colors.length];
        i++;
        return AnalysisData(
          label: e.key.toString(),
          amount: ParserUtils.toDouble(e.value),
          colorHex: color,
        );
      }).toList();
    } else {
      parsedAnalysis = const [];
    }

    return AppData(
      initialBalance: ParserUtils.toDouble(json['initialBalance'] ?? json['initial_balance']),
      totalIncome: ParserUtils.toDouble(json['totalIncome'] ?? json['total_income']),
      totalExpense: ParserUtils.toDouble(json['totalExpense'] ?? json['total_expense']),
      recentTransactions: ((json['recentTransactions'] ?? json['recent_transactions']) as List? ?? const [])
          .map((t) => Transaction.fromJson(t))
          .toList(),
      analysis: parsedAnalysis,
      spendingTarget: ParserUtils.toDouble(json['spendingTarget'] ?? json['spending_target']),
      targetPeriod: (json['targetPeriod'] ?? json['target_period']) as String?,
    );
  }

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
          description: 'Beli bahan makanan di pasar',
          amount: 500000,
          category: 'Food',
          date: '2026-04-10',
          type: TransactionType.expense,
        ),
      ],
      analysis: [
        AnalysisData(label: 'Food', amount: 3000000, colorHex: 'FF4242'),
      ],
    );
  }
}

class Transaction {
  final String? id;
  final String title;
  final String? description;
  final double amount;
  final String category;
  final String date;
  final TransactionType type;
  final String? source;
  final String? receiptUrl;
  final SyncStatus syncStatus;

  String get categoryKey => ParserUtils.normalizeCategory(category);

  Transaction({
    this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.source,
    this.receiptUrl,
    this.syncStatus = SyncStatus.synced,
  });

  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    String? date,
    TransactionType? type,
    String? source,
    String? receiptUrl,
    SyncStatus? syncStatus,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      source: source ?? this.source,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String dateStr = json['date']?.toString() ?? '';

    return Transaction(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? 'Transaksi',
      description: json['description']?.toString(),
      amount: ParserUtils.toDouble(json['amount']),
      category: json['category']?.toString() ?? 'Lainnya',
      date: dateStr,
      type: json['type']?.toString() == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      source: json['source']?.toString(),
      receiptUrl:
          json['receipt_url']?.toString() ?? json['receiptUrl']?.toString(),
      syncStatus: SyncStatus.synced,
    );
  }
}

class AnalysisData {
  final String label;
  final double amount;
  final String colorHex;

  String get categoryKey => ParserUtils.normalizeCategory(label);

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
