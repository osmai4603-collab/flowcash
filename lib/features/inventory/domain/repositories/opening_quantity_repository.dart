import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class OpeningQuantityRepository
    implements RepositoryDB<OpeningQuantityEntity> {
  Future<Either<Failure, OpeningQuantityEntity?>> getOpeningQuantity({
    required int inventoryId,
  });
  Future<Either<Failure, double>> getSumUnitsByInventory(int inventoryId);
  Future<Either<Failure, List<OpeningQuantityEntity>>> whereCommodity(
    InventoryEntity commodity,
  );
  Future<Either<Failure, List<OpeningQuantityEntity>>> whereStore(int storeId);
}
