import 'dart:io';

void main() {
  final file = File('lib/repositories/data_sources/remote/budget_remote_data_source.dart');
  var code = file.readAsStringSync();
  
  code = code.replaceAll(
'''  Future<List<BudgetModel>> getBudgets() async {
    final response = await _client.get('\${ApiConfig.baseUrl}/budgets');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiErrorException(body['message']?.toString() ?? 'Failed to load budgets');
    }
    final data = body['data'] as List? ?? [];
    return data.map((b) => BudgetModel.fromJson(b as Map<String, dynamic>)).toList();
  }''',
'''  Future<List<BudgetModel>> getAllBudgets() async {
    final data = await _client.get('\${ApiConfig.baseUrl}/budgets') as List? ?? [];
    return data.map((b) => BudgetModel.fromJson(b as Map<String, dynamic>)).toList();
  }'''
  );

  code = code.replaceAll(
'''  Future<List<BudgetStatusVM>> getBudgetStatus({String? month}) async {
    final params = month != null ? {'month': month} : <String, String>{};
    final uri = Uri.parse('\${ApiConfig.baseUrl}/budgets/status')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await _client.get(uri.toString());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiErrorException(body['message']?.toString() ?? 'Failed to load budget status');
    }
    final data = body['data'] as List? ?? [];
    return data.map((b) => BudgetStatusVM.fromJson(b as Map<String, dynamic>)).toList();
  }''',
'''  Future<List<BudgetStatusVM>> getBudgetStatus({String? month}) async {
    final params = month != null ? {'month': month} : <String, String>{};
    final uri = Uri.parse('\${ApiConfig.baseUrl}/budgets/status')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final data = await _client.get(uri.toString()) as List? ?? [];
    return data.map((b) => BudgetStatusVM.fromJson(b as Map<String, dynamic>)).toList();
  }'''
  );

  code = code.replaceAll(
'''  Future<BudgetModel> upsertBudget(Map<String, dynamic> data) async {
    final response = await _client.post(
      '\${ApiConfig.baseUrl}/budgets',
      body: data,
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiErrorException(body['message']?.toString() ?? 'Failed to save budget');
    }
    return BudgetModel.fromJson(body['data'] as Map<String, dynamic>);
  }''',
'''  Future<bool> saveBudget({required double amount, required String period, required String category, String? month}) async {
    try {
      await _client.post(
        '\${ApiConfig.baseUrl}/budgets',
        body: {'amount': amount, 'category_id': category, 'start_month': month ?? ''},
      );
      return true;
    } catch (_) {
      return false;
    }
  }'''
  );

  code = code.replaceAll(
'''  Future<BudgetModel> updateBudget(String id, Map<String, dynamic> data) async {
    final response = await _client.patch(
      '\${ApiConfig.baseUrl}/budgets/\$id',
      body: data,
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiErrorException(body['message']?.toString() ?? 'Failed to update budget');
    }
    return BudgetModel.fromJson(body['data'] as Map<String, dynamic>);
  }''',
'''  Future<BudgetModel> updateBudget(String id, Map<String, dynamic> data) async {
    final dataRes = await _client.patch('\${ApiConfig.baseUrl}/budgets/\$id', body: data) as Map<String, dynamic>;
    return BudgetModel.fromJson(dataRes);
  }'''
  );

  code = code.replaceAll(
'''  Future<void> deleteBudget(String id) async {
    final response = await _client.delete('\${ApiConfig.baseUrl}/budgets/\$id');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiErrorException(body['message']?.toString() ?? 'Failed to delete budget');
    }
  }''',
'''  Future<void> deleteBudget(String id) async {
    await _client.delete('\${ApiConfig.baseUrl}/budgets/\$id');
  }'''
  );

  file.writeAsStringSync(code);
}
