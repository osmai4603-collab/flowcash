import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';

abstract interface class CategoryAttributeDataSource
    implements
        AppDataSource<int, CategoryAttributeEntity, Map<String, dynamic>> {
  Future<List<CategoryAttributeEntity>> whereCategoryId(Iterable<int> ids);
  Future<List<CategoryAttributeEntity>> whereSubcategoryUnitId(
    Iterable<int> ids,
  );
}
