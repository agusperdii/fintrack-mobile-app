import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory(String name, String icon);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.get('$baseUrl/categories/');
    return (response as List).map((c) => CategoryModel.fromJson(c)).toList();
  }

  @override
  Future<CategoryModel> addCategory(String name, String icon) async {
    final response = await apiClient.post('$baseUrl/categories/', body: {
      'name': name,
      'icon': icon,
    });
    return CategoryModel.fromJson(response);
  }
}
