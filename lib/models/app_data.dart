import '../../core/utils/parser_utils.dart';

enum TransactionType { income, expense }

enum SyncStatus { idle, pending, syncing, synced, failed }

// ─── Category ─────────────────────────────────────────────────────────────────

class Category {
  final String id;
  final String? userId;
  final String name;
  final String type; // 'income' | 'expense'
  final String emoji;
  final String color;
  final bool isDefault;
  final DateTime? createdAt;

  Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.emoji,
    required this.color,
    this.isDefault = false,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      emoji: json['emoji']?.toString() ?? '📦',
      color: json['color']?.toString() ?? '#81ECFF',
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'type': type,
        'emoji': emoji,
        'color': color,
      };
}

// ─── Transaction ──────────────────────────────────────────────────────────────

class Transaction {
  final String id;
  final String? userId;
  final String? categoryId;
  final String? receiptId;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final String source; // 'manual' | 'ocr'
  final bool isConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;
  final SyncStatus syncStatus;

  Transaction({
    required this.id,
    this.userId,
    this.categoryId,
    this.receiptId,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    this.source = 'manual',
    this.isConfirmed = false,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.syncStatus = SyncStatus.synced,
  });

  /// Derive type from nested category
  TransactionType get type =>
      category?.type == 'income' ? TransactionType.income : TransactionType.expense;

  String get categoryKey => ParserUtils.normalizeCategory(category?.name ?? '');

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      receiptId: json['receipt_id']?.toString(),
      title: json['title']?.toString() ?? 'Transaksi',
      description: json['description']?.toString(),
      amount: ParserUtils.toDouble(json['amount']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      source: json['source']?.toString() ?? 'manual',
      isConfirmed: json['is_confirmed'] == true,
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

  /// Serialize to API request body (for POST/PATCH)
  Map<String, dynamic> toRequestJson() {
    // Format date as ISO 8601 with timezone offset for Jakarta (+07:00)
    final offset = '+07:00';
    final isoDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}$offset';
    return {
      'title': title,
      if (description != null) 'description': description,
      'amount': amount,
      'date': isoDate,
      if (categoryId != null) 'category_id': categoryId,
      if (receiptId != null) 'receipt_id': receiptId,
      'source': source,
      'is_confirmed': isConfirmed,
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? receiptId,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    String? source,
    bool? isConfirmed,
    Category? category,
    SyncStatus? syncStatus,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      receiptId: receiptId ?? this.receiptId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      source: source ?? this.source,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category ?? this.category,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

// ─── AnalysisData ─────────────────────────────────────────────────────────────

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
      label: json['categoryName']?.toString() ?? json['label'] as String? ?? '',
      amount: ParserUtils.toDouble(json['total'] ?? json['amount']),
      colorHex: json['color']?.toString() ?? json['colorHex'] as String? ?? '#81ECFF',
    );
  }
}

// ─── Dashboard sub-models ─────────────────────────────────────────────────────

class CheckInStatusVM {
  final bool isCheckedInToday;
  final int streakCount;

  CheckInStatusVM({required this.isCheckedInToday, required this.streakCount});

  factory CheckInStatusVM.fromJson(Map<String, dynamic> json) {
    // The caller passes either the full dashboard response (with checkInStatus wrapper)
    // or the unwrapped checkInStatus sub-object directly.
    // Accept both camelCase (dashboard/summary) and snake_case (dedicated endpoint).
    final s = json['checkInStatus'] as Map<String, dynamic>? ??
        json['check_in_status'] as Map<String, dynamic>? ??
        json;
    return CheckInStatusVM(
      isCheckedInToday: s['isCheckedInToday'] == true || s['is_checked_in_today'] == true,
      streakCount: (s['streakCount'] as num? ?? s['streak_count'] as num? ?? 0).toInt(),
    );
  }
}

class WeeklySpendingDay {
  final String day;
  final double amount;

  WeeklySpendingDay({required this.day, required this.amount});

  factory WeeklySpendingDay.fromJson(Map<String, dynamic> json) {
    return WeeklySpendingDay(
      day: json['day']?.toString() ?? '',
      amount: ParserUtils.toDouble(json['amount']),
    );
  }
}

class BudgetAlertVM {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final String color;
  final double spent;
  final double remaining;
  final double percentage;

  BudgetAlertVM({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.color,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory BudgetAlertVM.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>? ?? json;
    return BudgetAlertVM(
      categoryId: cat['id']?.toString() ?? '',
      categoryName: cat['name']?.toString() ?? '',
      emoji: cat['emoji']?.toString() ?? '💰',
      color: cat['color']?.toString() ?? '#81ECFF',
      spent: ParserUtils.toDouble(json['spent']),
      remaining: ParserUtils.toDouble(json['remaining']),
      percentage: ParserUtils.toDouble(json['percentage'] ?? json['percentage_used']),
    );
  }
}

class NotificationPopupVM {
  final String id;
  final String type;
  final String title;
  final String message;
  final String severity;
  final String presentation;
  final bool isRead;
  final DateTime createdAt;

  NotificationPopupVM({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.presentation,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationPopupVM.fromJson(Map<String, dynamic> json) {
    return NotificationPopupVM(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
      presentation: json['presentation']?.toString() ?? 'banner',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class WeeklyPulseVM {
  final List<WeeklySpendingDay> weeklySpending;
  final BudgetAlertVM? budgetAlert;
  final List<NotificationPopupVM> recentNotifications;
  final int unreadNotificationCount;

  WeeklyPulseVM({
    required this.weeklySpending,
    this.budgetAlert,
    required this.recentNotifications,
    required this.unreadNotificationCount,
  });

  double get growth {
    if (weeklySpending.length < 2) return 0.0;
    final today = weeklySpending.last.amount;
    final yesterday = weeklySpending[weeklySpending.length - 2].amount;
    if (yesterday == 0) return today > 0 ? 100.0 : 0.0;
    return ((today - yesterday) / yesterday) * 100;
  }

  List<double> get values => weeklySpending.map((e) => e.amount).toList();

  /// Aligns weekly spending to the current week (Monday to Sunday)
  /// Matches the SEN-MIN labels in the UI.
  List<double> get thisWeekValues {
    if (weeklySpending.isEmpty) return [0, 0, 0, 0, 0, 0, 0];
    
    final now = DateTime.now();
    // Monday = 1, ..., Sunday = 7
    final currentWeekday = now.weekday;
    
    // Calculate the date of Monday of this week
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    
    return List.generate(7, (index) {
      final targetDate = monday.add(Duration(days: index));
      final dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
      
      try {
        // Find entry that starts with YYYY-MM-DD
        return weeklySpending.firstWhere((s) => s.day.startsWith(dateStr)).amount;
      } catch (_) {
        return 0.0;
      }
    });
  }

  factory WeeklyPulseVM.fromJson(Map<String, dynamic> json) {
    // Caller already passes the weeklyPulse sub-object (already unwrapped).
    // Accept camelCase (dashboard/summary) and snake_case field names.
    final rawSpending = json['weeklySpending'] as List? ??
        json['weekly_spending'] as List? ?? [];
    final rawNotifs = json['recentNotifications'] as List? ??
        json['recent_notifications'] as List? ?? [];
    return WeeklyPulseVM(
      weeklySpending: rawSpending
          .map((e) => WeeklySpendingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetAlert: json['budgetAlert'] != null || json['budget_alert'] != null
          ? BudgetAlertVM.fromJson(
              (json['budgetAlert'] ?? json['budget_alert']) as Map<String, dynamic>)
          : null,
      recentNotifications: rawNotifs
          .map((e) => NotificationPopupVM.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadNotificationCount:
          (json['unreadNotificationCount'] as num? ??
              json['unread_notification_count'] as num? ??
              0)
              .toInt(),
    );
  }
}

// ─── AppData ──────────────────────────────────────────────────────────────────

class AppData {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final CheckInStatusVM? checkInStatus;
  final List<Transaction> recentTransactions;
  final WeeklyPulseVM? weeklyPulse;
  final String? targetPeriod; // YYYY-MM format from /dashboard/summary

  AppData({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.checkInStatus,
    required this.recentTransactions,
    this.weeklyPulse,
    this.targetPeriod,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    // GET /dashboard/summary response: { success: true, data: { ... } }
    // The caller already unwraps via _unwrap, so 'data' is the raw object.
    // Accept snake_case (API) keys.
    return AppData(
      balance: ParserUtils.toDouble(json['balance']),
      totalIncome: ParserUtils.toDouble(
          json['totalIncome'] ?? json['total_income'] ?? 0),
      totalExpense: ParserUtils.toDouble(
          json['totalExpense'] ?? json['total_expense'] ?? 0),
      checkInStatus: json['checkInStatus'] != null || json['check_in_status'] != null
          ? CheckInStatusVM.fromJson(
              (json['checkInStatus'] ?? json['check_in_status']) as Map<String, dynamic>)
          : null,
      recentTransactions: (json['recentTransactions'] as List? ??
              json['recent_transactions'] as List? ??
              [])
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      weeklyPulse: (json['weeklyPulse'] != null || json['weekly_pulse'] != null)
          ? WeeklyPulseVM.fromJson(
              (json['weeklyPulse'] ?? json['weekly_pulse']) as Map<String, dynamic>)
          : null,
      targetPeriod: json['targetPeriod']?.toString() ?? json['target_period']?.toString(),
    );
  }

  AppData copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpense,
    CheckInStatusVM? checkInStatus,
    List<Transaction>? recentTransactions,
    WeeklyPulseVM? weeklyPulse,
    String? targetPeriod,
  }) {
    return AppData(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      weeklyPulse: weeklyPulse ?? this.weeklyPulse,
      targetPeriod: targetPeriod ?? this.targetPeriod,
    );
  }
}