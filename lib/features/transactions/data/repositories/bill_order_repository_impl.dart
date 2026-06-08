import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_order_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_order_data_source.dart';

class BillOrderRepositoryImpl implements BillOrderRepository {
  final BillOrderDataSource _dataSource;

  const BillOrderRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<BillOrderEntity>>> get({
    Iterable<int>? ids,
  }) async {
    try {
      final result = await _dataSource.get(ids: ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillOrderEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillOrderEntity>> insert(
    BillOrderEntity entity,
  ) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return right(entityInserted);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillOrderEntity>> update(
    BillOrderEntity entity,
  ) async {
    try {
      await _dataSource.update(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return right(true);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BillOrderEntity>>> whereBillId(
    Iterable<int> ids,
  ) async {
    try {
      final result = await _dataSource.whereBillId(ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getSumUnitWhereOrder(
    int categoryId,
    int storeId,
  ) async {
    try {
      final result = await _dataSource.getSumUnitWhereOrder(
        categoryId,
        storeId,
      );
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillOrderEntity?>> firstWhereCategoryId(
    int categoryId,
  ) async {
    try {
      final result = await _dataSource.firstWhereCategoryId(categoryId);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BillOrderEntity>>> whereBatchId(
    Iterable<int> ids,
  ) async {
    try {
      final result = await _dataSource.whereBatchId(ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BillOrderEntity>>> whereInventory(
    int inventoryId,
  ) async {
    try {
      final result = await _dataSource.whereInventory(inventoryId);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
