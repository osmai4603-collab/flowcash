import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDataSource _dataSource;
  const InventoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<InventoryEntity>>> get({
    Iterable<int>? ids,
  }) async {
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
  Future<Either<Failure, InventoryEntity?>> getById(int id) async {
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
  Future<Either<Failure, InventoryEntity>> insert(
    InventoryEntity entity,
  ) async {
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
  Future<Either<Failure, InventoryEntity>> update(
    InventoryEntity entity,
  ) async {
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
  Future<Either<Failure, List<InventoryEntity>>> whereStore(int storeId) async {
    try {
      final res = await _dataSource.whereStore(storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryEntity?>> firstWhereCategory(
    int categoryId,
    int storeId,
  ) async {
    try {
      final res = await _dataSource.firstWhereCategory(categoryId, storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryEntity?>> firstWhereCategoryAndStore(
    int categoryId,
    int storeId,
  ) async {
    try {
      final res = await _dataSource.firstWhereCategoryAndStore(
        categoryId,
        storeId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryEntity>>> whereCategories(
    Iterable<int> ids, {
    required int storeId,
  }) async {
    try {
      final res = await _dataSource.whereCategories(ids, storeId: storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryEntity>> getInventory({
    required int categoryId,
    required int warehouseId,
  }) async {
    try {
      final res = await _dataSource.getInventory(
        categoryId: categoryId,
        warehouseId: warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
