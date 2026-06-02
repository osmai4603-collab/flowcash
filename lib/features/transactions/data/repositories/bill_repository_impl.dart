import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_data_source.dart';

class BillRepositoryImpl implements BillRepository {
  final BillDataSource _dataSource;

  const BillRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<BillEntity>>> get({Iterable<int>? ids}) async {
    try {
      final result = await _dataSource.get(ids: ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> insert(BillEntity entity) async {
    try {
      await _dataSource.insert(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> update(BillEntity entity) async {
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
  Future<Either<Failure, List<BillEntity>>> whereHasNotGoneInStore({
    bool trigger = false,
    bool printQuery = true,
  }) async {
    try {
      final result = await _dataSource.whereHasNotGoneInStore(
        trigger: trigger,
        printQuery: printQuery,
      );
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
