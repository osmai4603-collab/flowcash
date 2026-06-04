import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/opening_quantity_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/opening_quantity_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

class OpeningQuantityRepositoryImpl implements OpeningQuantityRepository {
  final OpeningQuantityDataSource _dataSource;
  const OpeningQuantityRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<OpeningQuantityEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, OpeningQuantityEntity?>> getById(int id) async {
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
  Future<Either<Failure, OpeningQuantityEntity>> insert(OpeningQuantityEntity entity) async {
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
  Future<Either<Failure, OpeningQuantityEntity>> update(OpeningQuantityEntity entity) async {
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
  Future<Either<Failure, OpeningQuantityEntity?>> getOpeningQuantity({required int storeId, required int categoryId}) async {
    try {
      final res = await _dataSource.getOpeningQuantity(storeId: storeId, categoryId: categoryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getSumUnitsWhereStoreAndCategory(int storeId, int categoryId) async {
    try {
      final res = await _dataSource.getSumUnitsWhereStoreAndCategory(storeId, categoryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OpeningQuantityEntity>>> whereCommodity(InventoryEntity commodity) async {
    try {
      final res = await _dataSource.whereCommodity(commodity);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OpeningQuantityEntity>>> whereStore(int storeId) async {
    try {
      final res = await _dataSource.whereStore(storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
