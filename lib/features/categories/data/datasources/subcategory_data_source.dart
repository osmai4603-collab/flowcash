import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';

abstract interface class SubcategoryLocalDataSource
    implements AppDataSource<int, SubcategoryEntity, Map<String, dynamic>> {
  Future<List<SubcategoryEntity>> whereMainCategoryId(Iterable<int> ids);
  Future<SubcategoryEntity?> firstWhereCategory(int categoryId);
  Future<List<SubcategoryUnitEntity>> getUnitsBySubcategoryIds(
    Iterable<int> ids,
  );
  Future<SubcategoryEntity> insertWithUnits(SubcategoryEntity entity);
  Future<SubcategoryUnitEntity> insertSubcategoryUnit(
    SubcategoryUnitEntity entity,
  );
  Future<SubcategoryUnitEntity> updateSubcategoryUnit(
    SubcategoryUnitEntity entity,
  );
  Future<SubcategoryEntity> saveWithUnits(
    SubcategoryEntity entity,
    List<SubcategoryUnitEntity> units,
  );
}
