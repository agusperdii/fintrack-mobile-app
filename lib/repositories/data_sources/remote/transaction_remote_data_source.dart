import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/app_data.dart';

abstract class TransactionRemoteDataSource {
  Future<List<Transaction>> getTransactions({String? month, int limit = 200});
  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  });
  Future<bool> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Transaction>> getTransactions({String? month, int limit = 200}) async {
    final response = await apiClient.get(
      '$baseUrl/transactions/',
      queryParameters: {
        'limit': limit.toString(),
        if (month != null) 'month': month,
      },
    );
    return (response as List).map((t) => Transaction.fromJson(t)).toList();
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
    await apiClient.post(
      '$baseUrl/transactions/',
      body: {
        'title': title,
        'description': description,
        'amount': amount,
        'category': category,
        'type': type.toLowerCase(),
        if (date != null) 'date': date.toIso8601String(),
      },
    );
    return true;
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    await apiClient.delete('$baseUrl/transactions/$id');
    return true;
  }
}
