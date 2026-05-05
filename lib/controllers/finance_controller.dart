import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/finance_repository.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/analysis_view_data.dart';
import 'package:savaio/models/checkin_data.dart';

class FinanceController extends ChangeNotifier {
  final FinanceRepository _repository;

  FinanceController(this._repository);

  // --- States ---
  AppData? _dashboardData;
  Map<String, dynamic>? _weeklyPulse;
  Map<String, String>? _userProfile;
  List<Map<String, dynamic>>? _allBudgets;
  List<Map<String, dynamic>>? _categories;
  List<NudgeData>? _nudges;
  List<NotificationData>? _notifications;
  CheckInStatus? _checkInStatus;
  List<Transaction>? _transactions;
  List<Map<String, dynamic>>? _monthlySummary;
  bool _isLoading = false;

  // --- Getters ---
  AppData? get dashboardData => _dashboardData;
  Map<String, dynamic>? get weeklyPulse => _weeklyPulse;
  Map<String, String>? get userProfile => _userProfile;
  List<Map<String, dynamic>> get allBudgets => _allBudgets ?? [];
  List<NudgeData> get nudges => _nudges ?? [];
  List<NotificationData> get notifications => _notifications ?? [];
  CheckInStatus? get checkInStatus => _checkInStatus;
  List<Transaction> get transactions => _transactions ?? [];
  List<Map<String, dynamic>> get monthlySummary => _monthlySummary ?? [];
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get categories => _categories ?? [];
  
  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  NudgeData? get latestUnreadNudge {
    if (nudges.isEmpty) return null;
    try {
      return nudges.firstWhere((n) => !n.isRead);
    } catch (_) {
      return nudges.first;
    }
  }
  
  dynamic getCategoryIcon(String name) {
    if (_categories == null) return Icons.category;
    final cat = _categories!.firstWhere(
      (c) => c['name'].toString().toLowerCase() == name.toLowerCase(), 
      orElse: () => {'icon': Icons.category},
    );
    return cat['icon'];
  }

  // --- Actions ---

  Future<void> loadInitialData() => fetchAllData();

  Future<void> fetchAllData({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _setLoading(true);
    
    try {
      if (forceRefresh) _repository.clearCache();

      final results = await Future.wait([
        _repository.getDashboardData(forceRefresh: forceRefresh),
        _repository.getWeeklyPulse(forceRefresh: forceRefresh),
        _repository.getUserProfile(forceRefresh: forceRefresh),
        _repository.getCategories(forceRefresh: forceRefresh),
        _repository.getNudges(forceRefresh: forceRefresh),
        _repository.getNotifications(forceRefresh: forceRefresh),
        _repository.getCheckInStatus(forceRefresh: forceRefresh),
        _repository.getAllBudgets(),
        _repository.getMonthlySummary(forceRefresh: forceRefresh),
        _repository.getTransactions(),
      ]);

      _dashboardData = results[0] as AppData;
      _weeklyPulse = results[1] as Map<String, dynamic>;
      _userProfile = results[2] as Map<String, String>;
      _categories = (results[3] as List<Map<String, dynamic>>).map((c) => {...c, 'isEmoji': true}).toList();
      _nudges = results[4] as List<NudgeData>;
      _notifications = results[5] as List<NotificationData>;
      _checkInStatus = results[6] as CheckInStatus;
      _allBudgets = results[7] as List<Map<String, dynamic>>;
      _monthlySummary = results[8] as List<Map<String, dynamic>>;
      _transactions = results[9] as List<Transaction>;

    } catch (e) {
      debugPrint("FinanceController Load Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<AnalysisViewData> getAnalysisViewData(String month) async {
    final raw = await _repository.getAnalysisSnapshot(month);
    return AnalysisViewData.fromMap(raw);
  }

  Future<void> fetchNudges() async {
    _nudges = await _repository.getNudges(forceRefresh: true);
    notifyListeners();
  }

  Future<void> markNudgeAsRead(String id) async {
    if (await _repository.markNudgeRead(id)) {
      await fetchNudges();
    }
  }

  Future<void> fetchNotifications() async {
    _notifications = await _repository.getNotifications(forceRefresh: true);
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    if (await _repository.markNotificationRead(id)) {
      await fetchNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    if (await _repository.deleteNotification(id)) {
      await fetchNotifications();
    }
  }

  Future<void> performCheckIn() async {
    if (await _repository.performCheckIn()) {
      _checkInStatus = await _repository.getCheckInStatus(forceRefresh: true);
      _notifications = await _repository.getNotifications(forceRefresh: true);
      notifyListeners();
    }
  }

  Future<List<Transaction>> fetchTransactions({String? month}) async {
    final txs = await _repository.getTransactions(month: month);
    _transactions = txs;
    notifyListeners();
    return txs;
  }

  void setTransactions(List<Transaction> txs) {
    _transactions = txs;
    notifyListeners();
  }

  double getSpentAmountFor(String category, String month) {
    if (_transactions == null) return 0.0;
    return _transactions!
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.date.startsWith(month))
        .where((t) => category.toLowerCase() == 'all' || t.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> updateSpendingTarget(double amount, String period, {String category = 'All', String? month}) async {
    if (await _repository.saveSpendingTarget(amount: amount, period: period, category: category, month: month)) {
      await fetchAllData(forceRefresh: true);
    }
  }

  Future<bool> addTransaction({required String title, String? description, required double amount, required String category, required String type, DateTime? date}) async {
    _setLoading(true);
    final success = await _repository.addTransaction(title: title, description: description, amount: amount, category: category, type: type, date: date);
    if (success) {
      await fetchAllData(forceRefresh: true);
    } else {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> deleteTransaction(String id) async {
    if (await _repository.deleteTransaction(id)) {
      await fetchAllData(forceRefresh: true);
      return true;
    }
    return false;
  }

  Future<bool> updateProfile({required String fullName, String? username}) async {
    if (await _repository.updateProfile(fullName: fullName, username: username)) {
      await fetchAllData(forceRefresh: true);
      return true;
    }
    return false;
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    return await _repository.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> addCustomCategory(String name, String icon) async {
    await _repository.addCategory(name, icon);
    await fetchAllData(forceRefresh: true);
  }

  Future<void> fetchMonthlySummary() async {
    _monthlySummary = await _repository.getMonthlySummary(forceRefresh: true);
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
