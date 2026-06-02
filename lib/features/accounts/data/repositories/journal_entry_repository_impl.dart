import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_entry_repository.dart';

class JournalEntryRepositoryImpl implements JournalEntryRepository {
  final JournalEntryDataSource _dataSource;
  const JournalEntryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<JournalEntryEntity>>> get({
    Iterable<int>? ids,
    bool getItems = false,
  }) async {
    try {
      final res = await _dataSource.get(ids: ids, getItems: getItems);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JournalEntryEntity?>> getById(
    int id, {
    bool getItems = false,
  }) async {
    try {
      final res = await _dataSource.getById(id, getItems: getItems);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JournalEntryEntity>> insert(
    JournalEntryEntity entity,
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
  Future<Either<Failure, JournalEntryEntity>> update(
    JournalEntryEntity entity,
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
  Future<Either<Failure, JournalEntryEntity>> saveWithItems(
    JournalEntryEntity entry,
    List<JournalItemEntity> items,
  ) async {
    try {
      final savedEntry = await _dataSource.saveWithItems(entry, items);
      return Right(savedEntry);
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
}
