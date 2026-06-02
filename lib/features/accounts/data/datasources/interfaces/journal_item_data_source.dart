import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

abstract interface class JournalItemDataSource
    implements AppDataSource<int, JournalItemEntity, Map<String, dynamic>> {
  Future<List<JournalItemEntity>> whereEntryId(int entryId);
  Future<List<JournalItemEntity>> whereAccountId(int accountId);
  Future<List<JournalItemEntity>> whereWarehouse(int warehouseId);
}
