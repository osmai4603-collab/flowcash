import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

abstract interface class MainCategoryLocalDataSource
    implements AppDataSource<int, MainCategoryEntity, Map<String, dynamic>> {
  Future<MainCategoryEntity?> firstWhereCategoryName(String categoryName);
}
