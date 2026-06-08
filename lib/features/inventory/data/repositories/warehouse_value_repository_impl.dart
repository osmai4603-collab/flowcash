import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_value_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_value_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';

class WarehouseValueRepositoryImpl implements WarehouseValueRepository {
  final WarehouseValueDataSource _dataSource;

  const WarehouseValueRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<WarehouseValueEntity>>> get({
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
  Future<Either<Failure, WarehouseValueEntity?>> getById(int id) async {
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
  Future<Either<Failure, WarehouseValueEntity>> insert(
    WarehouseValueEntity entity,
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
  Future<Either<Failure, WarehouseValueEntity>> update(
    WarehouseValueEntity entity,
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
  Future<Either<Failure, WarehouseValueEntity?>> fetchValue({
    required int warehouseId,
    required WarehouseValueType valueType,
  }) async {
    try {
      final res = await _dataSource.fetchValue(
        warehouseId: warehouseId,
        valueType: valueType,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> fetchDefaultSalesAccount({
    required int warehouseId,
  }) async {
    try {
      final res = await _dataSource.fetchDefaultSalesAccount(
        warehouseId: warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> fetchDefaultSalesReturnAccount({
    required int warehouseId,
  }) async {
    try {
      final res = await _dataSource.fetchDefaultSalesReturnAccount(
        warehouseId: warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> fetchDefaultBuysAccount({
    required int warehouseId,
  }) async {
    try {
      final res = await _dataSource.fetchDefaultBuysAccount(
        warehouseId: warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> fetchDefaultBuysReturnAccount({
    required int warehouseId,
  }) async {
    try {
      final res = await _dataSource.fetchDefaultBuysReturnAccount(
        warehouseId: warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<WarehouseValueType, WarehouseValueEntity>>>
  fetchAsMap() async {
    try {
      final res = await _dataSource.fetchAsMap();
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateValue({
    required String? value,
    required int id,
  }) async {
    try {
      final res = await _dataSource.updateValue(value: value, id: id);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
