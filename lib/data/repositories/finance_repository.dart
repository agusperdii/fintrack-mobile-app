import '../data_sources/remote_data_source.dart';
import '../models/app_data.dart';

class FinanceRepository {
  final RemoteDataSource remoteDataSource;

  FinanceRepository({required this.remoteDataSource});

  Future<AppData> getDashboardData() => remoteDataSource.getDashboardData();
  
  Future<List<AnalysisData>> getAnalysisData() => remoteDataSource.getAnalysisData();
  
  Future<Map<String, String>> getUserProfile() => remoteDataSource.getUserProfile();
  
  Future<Map<String, dynamic>> getSpendingTarget() => remoteDataSource.getSpendingTarget();

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) {
    return remoteDataSource.addTransaction(
      title: title,
      amount: amount,
      category: category,
      type: type,
    );
  }
}
