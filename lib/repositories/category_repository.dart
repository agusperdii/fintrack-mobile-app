import 'package:savaio/models/category_model.dart';
import 'package:savaio/repositories/data_sources/remote/category_remote_data_source.dart';

class CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepository(this._remoteDataSource);

  Future<List<CategoryModel>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  Future<CategoryModel> addCategory(String name, String icon) {
    return _remoteDataSource.addCategory(name, icon);
  }
}
