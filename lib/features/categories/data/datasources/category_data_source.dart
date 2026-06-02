import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';

abstract interface class CategoryLocalDataSource
    implements AppDataSource<int, CategoryEntity, Map<String, dynamic>> {
  Future<CategoryEntity?> firstWhereCategoryName(String categoryName);
  Future<bool> hasCategoryName(String categoryName);
  Future<List<CategoryEntity>> whereNotInStore(int storeId);
  Future<List<SimpleCategoryEntity>> whereCategoryNameContains(
    String categoryName, {
    int? limit,
  });
  Future<String> getNewCategoryNumber();
}
