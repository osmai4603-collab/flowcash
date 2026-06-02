import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class InventoryBatchRepository implements RepositoryDB<InventoryBatchEntity> {
  Future<Either<Failure, List<InventoryBatchEntity>>> whereCategoryIdAndStore(Iterable<int> ids, {required int storeId});
  Future<Either<Failure, List<InventoryBatchEntity>>> whereInventory(int inventoryId);
  Future<Either<Failure, double>> getUnitCost({required int inventoryId, required InventoryCostType unitCostType});
  Future<Either<Failure, InventoryBatchEntity?>> getBatch({required int inventoryId, required InventoryCostType unitCostType});
}
