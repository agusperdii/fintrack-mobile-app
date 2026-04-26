import '../data_sources/remote_data_source.dart';
import '../entities/app_data.dart';
import '../entities/nudge_data.dart';

class FinanceRepository {
  final RemoteDataSource remoteDataSource;

  FinanceRepository({required this.remoteDataSource});

  // --- In-Memory Cache ---
  AppData? _cachedDashboard;
  Map<String, String>? _cachedProfile;
  Map<String, dynamic>? _cachedTarget;
  List<Map<String, dynamic>>? _cachedSummary;

  Future<AppData> getDashboardData() async {
    try {
      final data = await remoteDataSource.getDashboardData();
      _cachedDashboard = data;
      return data;
    } catch (e) {
      if (_cachedDashboard != null) return _cachedDashboard!;
      rethrow;
    }
  }

  Future<List<AnalysisData>> getAnalysisData() => remoteDataSource.getAnalysisData();
  
  Future<Map<String, String>> getUserProfile() async {
    try {
      final data = await remoteDataSource.getUserProfile();
      _cachedProfile = data;
      return data;
    } catch (e) {
      if (_cachedProfile != null) return _cachedProfile!;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSpendingTarget() async {
    try {
      final data = await remoteDataSource.getSpendingTarget();
      _cachedTarget = data;
      return data;
    } catch (e) {
      if (_cachedTarget != null) return _cachedTarget!;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBudgets() => remoteDataSource.getAllBudgets();

  Future<Map<String, dynamic>> getWeeklyPulse() => remoteDataSource.getWeeklyPulse();

  Future<List<NudgeData>> getNudges() => remoteDataSource.getNudges();

  Future<bool> markNudgeRead(String id) => remoteDataSource.markNudgeRead(id);

  Future<bool> saveSpendingTarget({required double amount, required String period, String category = 'All', String? month}) =>
      remoteDataSource.saveSpendingTarget(amount: amount, period: period, category: category, month: month);

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) =>
      remoteDataSource.addTransaction(
        title: title,
        amount: amount,
        category: category,
        type: type,
        date: date,
      );

  Future<List<Transaction>> getTransactions({String? month}) => remoteDataSource.getTransactions(month: month);

  Future<bool> deleteTransaction(String id) => remoteDataSource.deleteTransaction(id);

  Future<bool> updateProfile({required String fullName, String? username}) => 
      remoteDataSource.updateProfile(fullName: fullName, username: username);

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) =>
      remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);

  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    try {
      final data = await remoteDataSource.getMonthlySummary();
      _cachedSummary = data;
      return data;
    } catch (e) {
      if (_cachedSummary != null) return _cachedSummary!;
      rethrow;
    }
  }
}
