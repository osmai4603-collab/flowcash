import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseDataSource _dataSource;
  const WarehouseRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<WarehouseEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, WarehouseEntity?>> getById(int id) async {
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
  Future<Either<Failure, WarehouseEntity>> insert(WarehouseEntity entity) async {
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
  Future<Either<Failure, WarehouseEntity>> update(WarehouseEntity entity) async {
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
  Future<Either<Failure, WarehouseEntity?>> getByCode(String code) async {
    try {
      final res = await _dataSource.getByCode(code);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
