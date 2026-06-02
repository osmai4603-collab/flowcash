import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class InventoryTransactionRepository implements RepositoryDB<InventoryTransactionEntity> {
  Future<Either<Failure, List<InventoryTransactionEntity>>> whereStoreId(Iterable<int> ids);
  Future<Either<Failure, Map<int, InventoryTransactionEntity>>> whereStoreToMap(int storeId);
  Future<Either<Failure, List<InventoryTransactionEntity>>> wherePersonId(Iterable<int> ids);
  Future<Either<Failure, List<InventoryTransactionEntity>>> whereStoreIdAndPersonId({required Iterable<int> storesIds, required Iterable<int> personsIds, bool trigger = false});
  Future<Either<Failure, List<int>>> getIdsWhereStore(int storeId);
}
