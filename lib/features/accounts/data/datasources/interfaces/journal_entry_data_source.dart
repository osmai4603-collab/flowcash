import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';

abstract interface class JournalEntryDataSource
    implements AppDataSource<int, JournalEntryEntity, Map<String, dynamic>> {
  @override
  Future<List<JournalEntryEntity>> get({
    Iterable<int>? ids,
    bool getItems = false,
  });

  @override
  Future<JournalEntryEntity?> getById(int id, {bool getItems = false});

  Future<List<JournalEntryEntity>> whereWarehouse(int warehouseId);
  Future<List<JournalEntryEntity>> whereCreatedBy(int userId);
  Future<JournalEntryEntity?> firstWhereReferenceNumber(String referenceNumber);
}
