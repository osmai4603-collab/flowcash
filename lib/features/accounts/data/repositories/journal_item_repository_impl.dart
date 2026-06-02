import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_item_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_item_repository.dart';

class JournalItemRepositoryImpl implements JournalItemRepository {
  final JournalItemDataSource _dataSource;

  const JournalItemRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<JournalItemEntity>>> get({
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
  Future<Either<Failure, JournalItemEntity?>> getById(int id) async {
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
  Future<Either<Failure, JournalItemEntity>> insert(
    JournalItemEntity entity,
  ) async {
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
  Future<Either<Failure, JournalItemEntity>> update(
    JournalItemEntity entity,
  ) async {
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
      return const Right(true);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JournalItemEntity>>> whereEntryId(
    int entryId,
  ) async {
    try {
      final res = await _dataSource.whereEntryId(entryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JournalItemEntity>>> whereAccountId(
    int accountId,
  ) async {
    try {
      final res = await _dataSource.whereAccountId(accountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JournalItemEntity>>> whereWarehouse(
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereWarehouse(warehouseId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
