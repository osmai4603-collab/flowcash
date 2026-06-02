import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';

abstract interface class InventoryBatchDataSource
    implements AppDataSource<int, InventoryBatchEntity, Map<String, dynamic>> {
  Future<List<InventoryBatchEntity>> whereCategoryIdAndStore(
    Iterable<int> ids, {
    required int storeId,
  });
  Future<List<InventoryBatchEntity>> whereInventory(int inventoryId);
  Future<double> getUnitCost({
    required int inventoryId,
    required InventoryCostType unitCostType,
  });
  Future<InventoryBatchEntity?> getBatch({
    required int inventoryId,
    required InventoryCostType unitCostType,
  });
}
