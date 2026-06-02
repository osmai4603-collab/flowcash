import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_item_repository.dart';

class GetJournalItemsUseCase {
  final JournalItemRepository _repository;

  const GetJournalItemsUseCase(this._repository);

  Future<Either<Failure, List<JournalItemEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetJournalItemByIdUseCase {
  final JournalItemRepository _repository;

  const GetJournalItemByIdUseCase(this._repository);

  Future<Either<Failure, JournalItemEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertJournalItemUseCase {
  final JournalItemRepository _repository;

  const InsertJournalItemUseCase(this._repository);

  Future<Either<Failure, JournalItemEntity>> call(
    JournalItemEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateJournalItemUseCase {
  final JournalItemRepository _repository;

  const UpdateJournalItemUseCase(this._repository);

  Future<Either<Failure, JournalItemEntity>> call(
    JournalItemEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteJournalItemUseCase {
  final JournalItemRepository _repository;

  const DeleteJournalItemUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetJournalItemsByEntryIdUseCase {
  final JournalItemRepository _repository;

  const GetJournalItemsByEntryIdUseCase(this._repository);

  Future<Either<Failure, List<JournalItemEntity>>> call(int entryId) async {
    return await _repository.whereEntryId(entryId);
  }
}

class GetJournalItemsByAccountIdUseCase {
  final JournalItemRepository _repository;

  const GetJournalItemsByAccountIdUseCase(this._repository);

  Future<Either<Failure, List<JournalItemEntity>>> call(int accountId) async {
    return await _repository.whereAccountId(accountId);
  }
}

class GetJournalItemsByWarehouseUseCase {
  final JournalItemRepository _repository;

  const GetJournalItemsByWarehouseUseCase(this._repository);

  Future<Either<Failure, List<JournalItemEntity>>> call(int warehouseId) async {
    return await _repository.whereWarehouse(warehouseId);
  }
}
