import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_catalog_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class InventorySubcategoryRepository implements RepositoryDB<InventorySubcategoryEntity> {
  Future<Either<Failure, InventorySubcategoryEntity?>> firstWhereStoreAndCategory({required int categoryId, required int warehouseId});
}
