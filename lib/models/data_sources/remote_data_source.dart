import '../entities/app_data.dart';

abstract class RemoteDataSource {
  Future<AppData> getDashboardData();
  Future<List<AnalysisData>> getAnalysisData();
  Future<Map<String, String>> getUserProfile();
  Future<Map<String, dynamic>> getSpendingTarget();
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  });
}

class RemoteDataSourceImpl implements RemoteDataSource {
  // Simulasi network delay
  final Duration _delay = const Duration(milliseconds: 800);

  @override
  Future<AppData> getDashboardData() async {
    await Future.delayed(_delay);
    return AppData.getDummyData();
  }

  @override
  Future<List<AnalysisData>> getAnalysisData() async {
    await Future.delayed(_delay);
    return AppData.getDummyData().analysis;
  }

  @override
  Future<Map<String, String>> getUserProfile() async {
    await Future.delayed(_delay);
    return {
      'name': 'Leonardo Da’vinci',
      'handle': '@agusperdii',
      'email': 'leonardo.davinci@kineticvault.com',
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCiFGzVgecqCYvbjM6FhDdTQVz1EKQsOleuJYWkMVimedbVz2KlbE9qZRle-eJwhTo_mV7NS_eR4jGNdnWrVD_7msFNNylsPL2r2IrK7FgJONfpwhwisWyxPR5Ot-qLnPQ2xmgXgL-AfGcZGchFV402cdgb0LuGOY4PmolelofW2jEO-eVSthHdXkjuMqhhA0_8Oq92iwdV59onMMEpwCeeIo0A90nzAnmh2Za2yRGwbwrxJAKJCkq0jwF4Ra2ylZExQgsJRg2tpDQ',
    };
  }

  @override
  Future<Map<String, dynamic>> getSpendingTarget() async {
    await Future.delayed(_delay);
    final data = AppData.getDummyData();
    return {
      'amount': data.spendingTarget ?? 0.0,
      'period': data.targetPeriod ?? 'Bulanan',
    };
  }

  @override
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    await Future.delayed(_delay);
    return true;
  }
}
