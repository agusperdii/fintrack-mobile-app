// budget_remote_data_source.dart
// Data source yang berkomunikasi langsung dengan endpoint budgets di
// backend (ambil daftar, status, simpan, perbarui, dan hapus budget).

import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/budget_model.dart';

class BudgetRemoteDataSource {
  final ApiClient _client;

  BudgetRemoteDataSource(this._client);

  /// GET /budgets — mengambil daftar seluruh budget.
  Future<List<BudgetModel>> getAllBudgets() async {
    final data = await _client.get('${ApiConfig.baseUrl}/budgets') as List? ?? [];
    return data.map((b) => BudgetModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  /// GET /budgets/status — mengambil status penggunaan budget.
  Future<List<BudgetStatusVM>> getBudgetStatus({String? month}) async {
    final params = month != null ? {'month': month} : <String, String>{};
    final uri = Uri.parse('${ApiConfig.baseUrl}/budgets/status')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final data = await _client.get(uri.toString()) as List? ?? [];
    return data.map((b) => BudgetStatusVM.fromJson(b as Map<String, dynamic>)).toList();
  }

  /// POST /budgets (upsert) — menyimpan atau memperbarui budget.
  Future<bool> saveBudget({required double amount, required String category, String? month}) async {
    final body = {
      'amount': amount,
      'category_id': category,
      if (month != null && month.isNotEmpty) 'start_month': month,
    };

    await _client.post(
      '${ApiConfig.baseUrl}/budgets',
      body: body,
    );
    return true;
  }

  /// PATCH /budgets/{id} — memperbarui budget berdasarkan id.
  Future<BudgetModel> updateBudget(String id, Map<String, dynamic> data) async {
    final dataRes = await _client.patch('${ApiConfig.baseUrl}/budgets/$id', body: data) as Map<String, dynamic>;
    return BudgetModel.fromJson(dataRes);
  }

  /// DELETE /budgets/{id} — menghapus budget berdasarkan id.
  Future<void> deleteBudget(String id) async {
    await _client.delete('${ApiConfig.baseUrl}/budgets/$id');
  }
}