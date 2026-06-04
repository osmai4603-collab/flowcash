import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/interfaces/accounting_period_repository.dart';
import 'package:flowcash/core/datasources/interfaces/accounting_period_data_source.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';

class AccountingPeriodRepositoryImpl implements AccountingPeriodRepository {
  final AccountingPeriodDataSource _dataSource;
  const AccountingPeriodRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AccountingPeriodEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, AccountingPeriodEntity?>> getById(int id) async {
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
  Future<Either<Failure, AccountingPeriodEntity>> insert(AccountingPeriodEntity entity) async {
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
  Future<Either<Failure, AccountingPeriodEntity>> update(AccountingPeriodEntity entity) async {
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
  Future<Either<Failure, AccountingPeriodEntity?>> whereIdOpen() async {
    try {
      final res = await _dataSource.whereIdOpen();
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
