import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_batch_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_batch_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';

class InventoryBatchRepositoryImpl implements InventoryBatchRepository {
  final InventoryBatchDataSource _dataSource;
  const InventoryBatchRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<InventoryBatchEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, InventoryBatchEntity?>> getById(int id) async {
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
  Future<Either<Failure, InventoryBatchEntity>> insert(InventoryBatchEntity entity) async {
    try {
      await _dataSource.insert(entity);
      return Right(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryBatchEntity>> update(InventoryBatchEntity entity) async {
    try {
      await _dataSource.update(entity);
      return Right(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return Right(true);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryBatchEntity>>> whereCategoryIdAndStore(Iterable<int> ids, {required int storeId}) async {
    try {
      final res = await _dataSource.whereCategoryIdAndStore(ids, storeId: storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryBatchEntity>>> whereInventory(int inventoryId) async {
    try {
      final res = await _dataSource.whereInventory(inventoryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getUnitCost({required int inventoryId, required InventoryCostType unitCostType}) async {
    try {
      final res = await _dataSource.getUnitCost(inventoryId: inventoryId, unitCostType: unitCostType);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryBatchEntity?>> getBatch({required int inventoryId, required InventoryCostType unitCostType}) async {
    try {
      final res = await _dataSource.getBatch(inventoryId: inventoryId, unitCostType: unitCostType);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
