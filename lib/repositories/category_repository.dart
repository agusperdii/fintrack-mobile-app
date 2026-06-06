import 'package:savaio/models/category_model.dart';
import 'package:savaio/repositories/data_sources/remote/category_remote_data_source.dart';

class CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepository(this._remoteDataSource);

  Future<List<CategoryModel>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  Future<CategoryModel> createCategory(String name, String icon, {String type = 'expense'}) {
    return _remoteDataSource.createCategory({
      'name': name,
      'emoji': icon,
      'type': type,
      'color': '#81ECFF',
    });
  }

  Future<void> deleteCategory(String id) {
    return _remoteDataSource.deleteCategory(id);
  }
}
