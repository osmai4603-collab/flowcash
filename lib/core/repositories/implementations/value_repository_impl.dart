import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/interfaces/value_repository.dart';
import 'package:flowcash/core/datasources/interfaces/value_data_source.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';

class ValueRepositoryImpl implements ValueRepository {
  final ValueDataSource _dataSource;
  const ValueRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ValueEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, ValueEntity?>> getById(int id) async {
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
  Future<Either<Failure, ValueEntity>> insert(ValueEntity entity) async {
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
  Future<Either<Failure, ValueEntity>> update(ValueEntity entity) async {
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
}
