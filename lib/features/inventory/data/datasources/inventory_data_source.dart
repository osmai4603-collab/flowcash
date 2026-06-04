import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_category_entity.dart';

abstract interface class InventoryDataSource
    implements AppDataSource<int, InventoryEntity, Map<String, dynamic>> {
  Future<List<InventoryEntity>> whereStore(int storeId);
  Future<InventoryEntity?> firstWhereCategory(int categoryId, int storeId);
  Future<InventoryEntity?> firstWhereCategoryAndStore(
    int categoryId,
    int storeId,
  );
  Future<List<InventoryEntity>> whereCategories(
    Iterable<int> ids, {
    required int storeId,
  });
  Future<InventoryEntity> getInventory({
    required int categoryId,
    required int warehouseId,
  });

  // Returns joined inventory + category records as `InventoryCategoryEntity`.
  Future<List<InventoryCategoryEntity>> getInventoryCategories({
    int? warehouseId,
  });

  Future<InventoryCategoryEntity?> getInventoryCategoryByInventoryId(int id);
}
