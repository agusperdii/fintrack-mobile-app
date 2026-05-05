import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/models/mock_data.dart';

abstract class RemoteDataSource {
  Future<AppData> getDashboardData();
  Future<Map<String, dynamic>> getAnalysisSnapshot(String month);
  Future<List<AnalysisData>> getAnalysisData({String? month});
  Future<Map<String, String>> getUserProfile();
  Future<Map<String, dynamic>> getSpendingTarget();
  Future<List<Map<String, dynamic>>> getAllBudgets();
  Future<Map<String, dynamic>> getWeeklyPulse();
  Future<List<NudgeData>> getNudges();
  Future<bool> markNudgeRead(String id);
  Future<List<NotificationData>> getNotifications();
  Future<bool> markNotificationRead(String id);
  Future<bool> deleteNotification(String id);
  Future<CheckInStatus> getCheckInStatus();
  Future<bool> performCheckIn();
  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month});
  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  });
  Future<List<Transaction>> getTransactions({String? month, int? limit});
  Future<bool> deleteTransaction(String id);
  Future<bool> updateProfile({required String fullName, String? username});
  Future<bool> updatePassword({required String currentPassword, required String newPassword});
  Future<List<Map<String, dynamic>>> getMonthlySummary();
  Future<List<Map<String, dynamic>>> getCategories();
  Future<Map<String, dynamic>> addCategory(String name, String icon);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  // Session-based in-memory state
  final List<Transaction> _transactions = List.from(MockData.transactions);
  final List<NotificationData> _notifications = List.from(MockData.notifications);
  final List<NudgeData> _nudges = List.from(MockData.nudges);
  final List<Map<String, dynamic>> _categories = List.from(MockData.categories);
  final Map<String, String> _userProfile = Map.from(MockData.userProfile);
  Map<String, dynamic> _spendingTarget = Map.from(MockData.spendingTarget);
  CheckInStatus _checkInStatus = MockData.checkInStatus;

  @override
  Future<Map<String, dynamic>> getAnalysisSnapshot(String month) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Map<String, dynamic>.from(MockData.analysisSnapshot);
  }

  @override
  Future<AppData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    double income = 0;
    double expense = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    final analysis = await getAnalysisData();

    return AppData(
      initialBalance: 12500000.0,
      totalIncome: income,
      totalExpense: expense,
      recentTransactions: _transactions.take(5).toList(),
      analysis: analysis,
    );
  }

  @override
  Future<List<AnalysisData>> getAnalysisData({String? month}) async {
    final snap = await getAnalysisSnapshot(month ?? '');
    final List raw = snap['category_breakdown'];
    return raw.map((e) => AnalysisData(
      label: e['label'],
      amount: e['amount'],
      colorHex: e['color'],
    )).toList();
  }

  @override
  Future<Map<String, String>> getUserProfile() async => _userProfile;

  @override
  Future<Map<String, dynamic>> getSpendingTarget() async => _spendingTarget;

  @override
  Future<List<Map<String, dynamic>>> getAllBudgets() async => [_spendingTarget];

  @override
  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month}) async {
    _spendingTarget = {'amount': amount, 'period': period, 'category': category};
    return true;
  }

  @override
  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) async {
    _transactions.insert(0, Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      amount: amount,
      category: category,
      type: type.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense,
      date: (date ?? DateTime.now()).toIso8601String(),
    ));
    return true;
  }

  @override
  Future<List<Transaction>> getTransactions({String? month, int? limit}) async {
    var list = _transactions;
    if (limit != null) return list.take(limit).toList();
    return list;
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    return true;
  }

  @override
  Future<bool> updateProfile({required String fullName, String? username}) async {
    _userProfile['name'] = fullName;
    if (username != null) _userProfile['handle'] = '@$username';
    return true;
  }

  @override
  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async => true;

  @override
  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    return [
      {'month': '2026-05', 'income': 8500000.0, 'expense': 4200000.0, 'count': 12},
      {'month': '2026-04', 'income': 7500000.0, 'expense': 3800000.0, 'count': 10},
    ];
  }

  @override
  Future<List<NudgeData>> getNudges() async => _nudges;

  @override
  Future<bool> markNudgeRead(String id) async {
    final i = _nudges.indexWhere((n) => n.id == id);
    if (i != -1) {
      final old = _nudges[i];
      _nudges[i] = NudgeData(id: old.id, type: old.type, message: old.message, isRead: true, createdAt: old.createdAt);
    }
    return true;
  }

  @override
  Future<List<NotificationData>> getNotifications() async => _notifications;

  @override
  Future<bool> markNotificationRead(String id) async {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i != -1) {
      final old = _notifications[i];
      _notifications[i] = NotificationData(id: old.id, title: old.title, message: old.message, type: old.type, isRead: true, createdAt: old.createdAt);
    }
    return true;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    return true;
  }

  @override
  Future<CheckInStatus> getCheckInStatus() async => _checkInStatus;

  @override
  Future<bool> performCheckIn() async {
    _checkInStatus = CheckInStatus(streakCount: _checkInStatus.streakCount + 1, lastCheckinDate: DateTime.now(), isCheckedInToday: true);
    return true;
  }

  @override
  Future<Map<String, dynamic>> getWeeklyPulse() async => MockData.weeklyPulse;

  @override
  Future<List<Map<String, dynamic>>> getCategories() async => _categories;

  @override
  Future<Map<String, dynamic>> addCategory(String name, String icon) async {
    final c = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'name': name, 'icon': icon, 'is_system': false};
    _categories.add(c);
    return c;
  }
}
