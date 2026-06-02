import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';

abstract interface class CategoryPropertyDataSource
    implements
        AppDataSource<int, CategoryPropertyEntity, Map<String, dynamic>> {
  Future<List<CategoryPropertyEntity>> whereMainCategoryId(Iterable<int> ids);
}
