// weekly_pulse_model.dart
// Model data untuk ringkasan aktivitas mingguan (weekly pulse) pengguna,
// mencakup pengeluaran harian, peringatan budget, dan notifikasi terkini.

import '../core/utils/parser_utils.dart';

/// Weekly pulse dari GET /analytics?month=YYYY-MM → data.weeklyPulse
class WeeklyPulseModel {
  final List<WeeklySpendingDay> weeklySpending;
  final BudgetAlert? budgetAlert;
  final List<NotificationSummary> recentNotifications;
  final int unreadNotificationCount;

  WeeklyPulseModel({
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

  factory WeeklyPulseModel.fromJson(Map<String, dynamic> json) {
    final pulse = json['weeklyPulse'] as Map<String, dynamic>? ??
        json['weekly_pulse'] as Map<String, dynamic>? ??
        json;
    return WeeklyPulseModel(
      weeklySpending: (pulse['weeklySpending'] as List? ??
              json['weeklySpending'] as List? ??
              [])
          .map((e) => WeeklySpendingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetAlert: pulse['budgetAlert'] != null || json['budgetAlert'] != null
          ? BudgetAlert.fromJson(
              (pulse['budgetAlert'] ?? json['budgetAlert']) as Map<String, dynamic>)
          : null,
      recentNotifications: (pulse['recentNotifications'] as List? ??
              json['recentNotifications'] as List? ??
              [])
          .map((e) => NotificationSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadNotificationCount:
          (pulse['unreadNotificationCount'] as num?)?.toInt() ??
          (json['unreadNotificationCount'] as num?)?.toInt() ??
          0,
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

class BudgetAlert {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final String color;
  final double spent;
  final double remaining;
  final double percentage;

  BudgetAlert({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.color,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>? ?? json;
    return BudgetAlert(
      categoryId: cat['id']?.toString() ?? '',
      categoryName: cat['name']?.toString() ?? '',
      emoji: cat['emoji']?.toString() ?? '💰',
      color: cat['color']?.toString() ?? '#81ECFF',
      spent: ParserUtils.toDouble(json['spent']),
      remaining: ParserUtils.toDouble(json['remaining']),
      percentage:
          ParserUtils.toDouble(json['percentage'] ?? json['percentage_used']),
    );
  }
}

class NotificationSummary {
  final String id;
  final String type;
  final String title;
  final String message;
  final String severity;
  final String presentation;

  NotificationSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.presentation,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
      presentation: json['presentation']?.toString() ?? 'banner',
    );
  }
}