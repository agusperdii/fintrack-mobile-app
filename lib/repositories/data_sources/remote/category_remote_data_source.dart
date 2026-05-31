import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/category_model.dart';

class CategoryRemoteDataSource {
  final ApiClient _client;

  CategoryRemoteDataSource(this._client);

  /// GET /categories
  Future<List<CategoryModel>> getCategories() async {
    final data = await _client.get('${ApiConfig.baseUrl}/categories') as List? ?? [];
    return data.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  /// POST /categories
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final resData = await _client.post(
      '${ApiConfig.baseUrl}/categories',
      body: data,
    ) as Map<String, dynamic>;
    return CategoryModel.fromJson(resData);
  }

  /// PATCH /categories/{id}
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final resData = await _client.patch(
      '${ApiConfig.baseUrl}/categories/$id',
      body: data,
    ) as Map<String, dynamic>;
    return CategoryModel.fromJson(resData);
  }

  /// DELETE /categories/{id}
  Future<void> deleteCategory(String id) async {
    await _client.delete('${ApiConfig.baseUrl}/categories/$id');
  }
}
