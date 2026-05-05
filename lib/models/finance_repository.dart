import 'package:savaio/models/remote_data_source.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/checkin_data.dart';

class FinanceRepository {
  final RemoteDataSource remoteDataSource;

  FinanceRepository({required this.remoteDataSource});

  // --- In-Memory Cache ---
  AppData? _cachedDashboard;
  Map<String, String>? _cachedProfile;
  Map<String, dynamic>? _cachedTarget;
  List<Map<String, dynamic>>? _cachedSummary;
  Map<String, dynamic>? _cachedWeeklyPulse;
  List<Map<String, dynamic>>? _cachedCategories;
  List<NudgeData>? _cachedNudges;
  List<NotificationData>? _cachedNotifications;
  CheckInStatus? _cachedCheckInStatus;

  Future<AppData> getDashboardData({bool forceRefresh = false}) async {
    if (_cachedDashboard != null && !forceRefresh) return _cachedDashboard!;
    final data = await remoteDataSource.getDashboardData();
    _cachedDashboard = data;
    return data;
  }

  Future<Map<String, dynamic>> getAnalysisSnapshot(String month) {
    // No caching, always fetch from remote
    return remoteDataSource.getAnalysisSnapshot(month);
  }

  Future<Map<String, String>> getUserProfile({bool forceRefresh = false}) async {
    if (_cachedProfile != null && !forceRefresh) return _cachedProfile!;
    final data = await remoteDataSource.getUserProfile();
    _cachedProfile = data;
    return data;
  }

  Future<Map<String, dynamic>> getSpendingTarget({bool forceRefresh = false}) async {
    if (_cachedTarget != null && !forceRefresh) return _cachedTarget!;
    final data = await remoteDataSource.getSpendingTarget();
    _cachedTarget = data;
    return data;
  }

  Future<List<Map<String, dynamic>>> getAllBudgets() => remoteDataSource.getAllBudgets();

  Future<Map<String, dynamic>> getWeeklyPulse({bool forceRefresh = false}) async {
    if (_cachedWeeklyPulse != null && !forceRefresh) return _cachedWeeklyPulse!;
    final data = await remoteDataSource.getWeeklyPulse();
    _cachedWeeklyPulse = data;
    return data;
  }

  Future<List<NudgeData>> getNudges({bool forceRefresh = false}) async {
    if (_cachedNudges != null && !forceRefresh) return _cachedNudges!;
    final data = await remoteDataSource.getNudges();
    _cachedNudges = data;
    return data;
  }

  Future<bool> markNudgeRead(String id) async {
    final success = await remoteDataSource.markNudgeRead(id);
    if (success && _cachedNudges != null) {
      final index = _cachedNudges!.indexWhere((n) => n.id == id);
      if (index != -1) {
        _cachedNudges![index] = NudgeData(
          id: _cachedNudges![index].id,
          type: _cachedNudges![index].type,
          category: _cachedNudges![index].category,
          message: _cachedNudges![index].message,
          isRead: true,
          createdAt: _cachedNudges![index].createdAt,
        );
      }
    }
    return success;
  }

  Future<List<NotificationData>> getNotifications({bool forceRefresh = false}) async {
    if (_cachedNotifications != null && !forceRefresh) return _cachedNotifications!;
    final data = await remoteDataSource.getNotifications();
    _cachedNotifications = data;
    return data;
  }

  Future<bool> markNotificationRead(String id) async {
    final success = await remoteDataSource.markNotificationRead(id);
    if (success && _cachedNotifications != null) {
      final index = _cachedNotifications!.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _cachedNotifications![index];
        _cachedNotifications![index] = NotificationData(
          id: old.id, title: old.title, message: old.message,
          type: old.type, isRead: true, createdAt: old.createdAt, extraData: old.extraData,
        );
      }
    }
    return success;
  }

  Future<bool> deleteNotification(String id) async {
    final success = await remoteDataSource.deleteNotification(id);
    if (success) _cachedNotifications?.removeWhere((n) => n.id == id);
    return success;
  }

  Future<CheckInStatus> getCheckInStatus({bool forceRefresh = false}) async {
    if (_cachedCheckInStatus != null && !forceRefresh) return _cachedCheckInStatus!;
    final data = await remoteDataSource.getCheckInStatus();
    _cachedCheckInStatus = data;
    return data;
  }

  Future<bool> performCheckIn() async {
    final success = await remoteDataSource.performCheckIn();
    if (success) {
      _cachedCheckInStatus = null; // Invalidate to force reload
    }
    return success;
  }

  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month}) async {
    final success = await remoteDataSource.saveSpendingTarget(amount: amount, period: period, category: category, month: month);
    if (success) _cachedTarget = null;
    return success;
  }

  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) async {
    final success = await remoteDataSource.addTransaction(
      title: title,
      description: description,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );
    if (success) {
      _cachedDashboard = null; // Invalidate
      _cachedSummary = null;
      _cachedWeeklyPulse = null;
    }
    return success;
  }

  Future<List<Transaction>> getTransactions({String? month, int? limit}) => remoteDataSource.getTransactions(month: month, limit: limit);

  Future<bool> deleteTransaction(String id) async {
    final success = await remoteDataSource.deleteTransaction(id);
    if (success) {
      _cachedDashboard = null;
      _cachedSummary = null;
      _cachedWeeklyPulse = null;
    }
    return success;
  }

  Future<bool> updateProfile({required String fullName, String? username}) async {
    final success = await remoteDataSource.updateProfile(fullName: fullName, username: username);
    if (success) _cachedProfile = null;
    return success;
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) =>
      remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);

  Future<List<Map<String, dynamic>>> getMonthlySummary({bool forceRefresh = false}) async {
    if (_cachedSummary != null && !forceRefresh) return _cachedSummary!;
    final data = await remoteDataSource.getMonthlySummary();
    _cachedSummary = data;
    return data;
  }

  Future<List<Map<String, dynamic>>> getCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) return _cachedCategories!;
    final data = await remoteDataSource.getCategories();
    _cachedCategories = data;
    return data;
  }
  
  Future<Map<String, dynamic>> addCategory(String name, String icon) async {
    final data = await remoteDataSource.addCategory(name, icon);
    _cachedCategories = null;
    return data;
  }

  void clearCache() {
    _cachedDashboard = null;
    _cachedProfile = null;
    _cachedTarget = null;
    _cachedSummary = null;
    _cachedWeeklyPulse = null;
    _cachedCategories = null;
    _cachedNudges = null;
    _cachedNotifications = null;
    _cachedCheckInStatus = null;
  }
}
