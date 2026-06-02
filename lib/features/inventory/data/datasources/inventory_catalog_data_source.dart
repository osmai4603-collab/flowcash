import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_catalog_entity.dart';

abstract interface class InventorySubcategoryDataSource
    implements
        AppDataSource<int, InventorySubcategoryEntity, Map<String, dynamic>> {
  Future<InventorySubcategoryEntity?> firstWhereStoreAndCategory({
    required int categoryId,
    required int warehouseId,
  });
}
