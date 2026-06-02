import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class InventoryRepository implements RepositoryDB<InventoryEntity> {
  Future<Either<Failure, List<InventoryEntity>>> whereStore(int storeId);
  Future<Either<Failure, InventoryEntity?>> firstWhereCategory(int categoryId, int storeId);
  Future<Either<Failure, InventoryEntity?>> firstWhereCategoryAndStore(int categoryId, int storeId);
  Future<Either<Failure, List<InventoryEntity>>> whereCategories(Iterable<int> ids, {required int storeId});
  Future<Either<Failure, InventoryEntity>> getInventory({required int categoryId, required int warehouseId});
}
