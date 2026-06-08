import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/repositories/exchange_price_repository.dart';
import 'package:flowcash/features/currencies/data/datasources/exchange_price_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';

class ExchangePriceRepositoryImpl implements ExchangePriceRepository {
  final ExchangePriceDataSource _dataSource;
  const ExchangePriceRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ExchangePriceEntity>>> get({
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
  Future<Either<Failure, ExchangePriceEntity?>> getById(int id) async {
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
  Future<Either<Failure, ExchangePriceEntity>> insert(
    ExchangePriceEntity entity,
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
  Future<Either<Failure, ExchangePriceEntity>> update(
    ExchangePriceEntity entity,
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
  Future<Either<Failure, double>> getExPrice(
    String fromCurrencyId,
    String toCurrencyId,
  ) async {
    try {
      final res = await _dataSource.getExPrice(fromCurrencyId, toCurrencyId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExchangePriceEntity>>> getWhereFromCurrencyId(
    Iterable<String> ids,
  ) async {
    try {
      final res = await _dataSource.getWhereFromCurrencyId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
