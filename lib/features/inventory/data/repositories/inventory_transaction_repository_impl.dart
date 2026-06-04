import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_transaction_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';

class InventoryTransactionRepositoryImpl implements InventoryTransactionRepository {
  final InventoryTransactionDataSource _dataSource;
  const InventoryTransactionRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<InventoryTransactionEntity>>> get({Iterable<int>? ids}) async {
    try {
      final res = await _dataSource.get(ids: ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryTransactionEntity?>> getById(int id) async {
    try {
      final res = await _dataSource.getById(id);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryTransactionEntity>> insert(InventoryTransactionEntity entity) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return Right(entityInserted);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryTransactionEntity>> update(InventoryTransactionEntity entity) async {
    try {
      final entityUpdated = await _dataSource.update(entity);
      return Right(entityUpdated);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final result = await _dataSource.delete(id);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryTransactionEntity>>> whereStoreId(Iterable<int> ids) async {
    try {
      final res = await _dataSource.whereStoreId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<int, InventoryTransactionEntity>>> whereStoreToMap(int storeId) async {
    try {
      final res = await _dataSource.whereStoreToMap(storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryTransactionEntity>>> wherePersonId(Iterable<int> ids) async {
    try {
      final res = await _dataSource.wherePersonId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryTransactionEntity>>> whereStoreIdAndPersonId({required Iterable<int> storesIds, required Iterable<int> personsIds, bool trigger = false}) async {
    try {
      final res = await _dataSource.whereStoreIdAndPersonId(storesIds: storesIds, personsIds: personsIds, trigger: trigger);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getIdsWhereStore(int storeId) async {
    try {
      final res = await _dataSource.getIdsWhereStore(storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
