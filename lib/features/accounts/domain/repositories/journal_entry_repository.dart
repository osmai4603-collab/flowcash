import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

abstract interface class JournalEntryRepository
    implements RepositoryDB<JournalEntryEntity> {
  @override
  Future<Either<Failure, List<JournalEntryEntity>>> get({
    Iterable<int>? ids,
    bool getItems = false,
  });

  @override
  Future<Either<Failure, JournalEntryEntity?>> getById(
    int id, {
    bool getItems = false,
  });

  Future<Either<Failure, JournalEntryEntity>> saveWithItems(
    JournalEntryEntity entry,
    List<JournalItemEntity> items,
  );
}
