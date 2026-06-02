import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_entry_repository.dart';

class GetJournalEntriesUseCase {
  final JournalEntryRepository _repository;

  const GetJournalEntriesUseCase(this._repository);

  Future<Either<Failure, List<JournalEntryEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids, getItems: true);
  }
}

class GetJournalEntryByIdUseCase {
  final JournalEntryRepository _repository;

  const GetJournalEntryByIdUseCase(this._repository);

  Future<Either<Failure, JournalEntryEntity?>> call(int id) async {
    return await _repository.getById(id, getItems: true);
  }
}

class InsertJournalEntryUseCase {
  final JournalEntryRepository _repository;

  const InsertJournalEntryUseCase(this._repository);

  Future<Either<Failure, JournalEntryEntity>> call(
    JournalEntryEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateJournalEntryUseCase {
  final JournalEntryRepository _repository;

  const UpdateJournalEntryUseCase(this._repository);

  Future<Either<Failure, JournalEntryEntity>> call(
    JournalEntryEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteJournalEntryUseCase {
  final JournalEntryRepository _repository;

  const DeleteJournalEntryUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class SaveJournalEntryWithItemsUseCase {
  final JournalEntryRepository _repository;

  const SaveJournalEntryWithItemsUseCase(this._repository);

  Future<Either<Failure, JournalEntryEntity>> call(
    JournalEntryEntity entry,
    List<JournalItemEntity> items,
  ) async {
    return await _repository.saveWithItems(entry, items);
  }
}
