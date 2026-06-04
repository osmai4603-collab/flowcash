import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/repositories/currency_repository.dart';
import 'package:flowcash/features/currencies/data/datasources/currency_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyDataSource _dataSource;
  const CurrencyRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CurrencyEntity>>> get({Iterable<String>? ids}) async {
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
  Future<Either<Failure, CurrencyEntity?>> getById(String id) async {
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
  Future<Either<Failure, CurrencyEntity>> insert(CurrencyEntity entity) async {
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
  Future<Either<Failure, CurrencyEntity>> update(CurrencyEntity entity) async {
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
  Future<Either<Failure, bool>> delete(String id) async {
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
  Future<Either<Failure, List<CurrencyEntity>>> whereSelected() async {
    try {
      final res = await _dataSource.whereSelected();
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CurrencyEntity>>> whereNotSelected() async {
    try {
      final res = await _dataSource.whereNotSelected();
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
