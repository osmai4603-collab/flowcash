import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

abstract interface class JournalItemRepository
    implements RepositoryDB<JournalItemEntity> {
  Future<Either<Failure, List<JournalItemEntity>>> whereEntryId(int entryId);
  Future<Either<Failure, List<JournalItemEntity>>> whereAccountId(
    int accountId,
  );
  Future<Either<Failure, List<JournalItemEntity>>> whereWarehouse(
    int warehouseId,
  );
}
