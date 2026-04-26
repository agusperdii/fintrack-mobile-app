import '../data_sources/remote_data_source.dart';
import '../entities/app_data.dart';

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

  Future<bool> saveSpendingTarget({required double amount, required String period}) =>
      remoteDataSource.saveSpendingTarget(amount: amount, period: period);

  Future<bool> addTransaction({required String title, required double amount, required String category, required String type}) =>
      remoteDataSource.addTransaction(title: title, amount: amount, category: category, type: type);

  Future<List<Transaction>> getTransactions({String? month}) => remoteDataSource.getTransactions(month: month);

  Future<bool> deleteTransaction(String id) => remoteDataSource.deleteTransaction(id);

  Future<bool> updateProfile({required String fullName}) => remoteDataSource.updateProfile(fullName: fullName);

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
