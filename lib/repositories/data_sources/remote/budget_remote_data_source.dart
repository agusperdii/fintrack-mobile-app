import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getAllBudgets();
  Future<bool> saveBudget({
    required double amount,
    required String period,
    String category = 'All',
    String? month,
  });
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  BudgetRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    final response = await apiClient.get('$baseUrl/budgets/');
    return (response as List).map((b) => BudgetModel.fromJson(b)).toList();
  }

  @override
  Future<bool> saveBudget({
    required double amount,
    required String period,
    String category = 'All',
    String? month,
  }) async {
    String monthStr = month ?? "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    await apiClient.post('$baseUrl/budgets/', body: {
      'category': category,
      'amount': amount,
      'month': monthStr,
    });
    return true;
  }
}
