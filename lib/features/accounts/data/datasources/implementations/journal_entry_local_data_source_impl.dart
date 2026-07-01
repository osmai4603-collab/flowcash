import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/data/models/journal_entry_model.dart';
import 'package:flowcash/features/accounts/data/models/journal_item_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';

final class JournalEntryLocalDataSourceImpl implements JournalEntryDataSource {
  final SqliteDatabase db;
  final Map<String, dynamic> Function(JournalItemEntity) journalItemToMap;
  const JournalEntryLocalDataSourceImpl(this.db, this.journalItemToMap);

  @override
  Future<List<JournalEntryEntity>> get({
    Iterable<int>? ids,
    bool getItems = false,
  }) async {
    final rows = ids == null
        ? await db.query(table: JournalEntriesTable().tableName)
        : await db.query(
            table: JournalEntriesTable().tableName,
            where:
                '${JournalEntriesTable().id} IN (${List.filled(ids.length, '?').join(', ')})',
            whereArgs: ids.toList(),
          );

    final entries = rows.map(fromMap).toList();
    if (!getItems || entries.isEmpty) return entries;

    final entryIds = entries.map((e) => e.id).toList();
    final itemsByEntry = await _getJournalItemsByEntryIds(entryIds);
    return entries.map((entry) {
      return entry.copyWith(items: itemsByEntry[entry.id] ?? []);
    }).toList();
  }

  @override
  Future<JournalEntryEntity?> getById(int id, {bool getItems = false}) async {
    final rows = await db.query(
      table: JournalEntriesTable().tableName,
      where: '${JournalEntriesTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final entry = fromMap(rows.first);
    if (!getItems) return entry;

    final items = await _getJournalItemsByEntryId(entry.id);
    return entry.copyWith(items: items);
  }

  @override
  Future<JournalEntryEntity> insert(JournalEntryEntity entity) async {
    return await db.transaction(() async {
      final entryId = await db.insert(
        table: JournalEntriesTable().tableName,
        data: toMap(entity),
      );

      if (entryId <= 0) {
        throw Exception('Failed to insert journal entry');
      }

      for (var index = 0; index < entity.items.length; index++) {
        final item = entity.items[index].copyWith(entryId: entryId);
        final itemId = await db.insert(
          table: JournalItemsTable().tableName,
          data: journalItemToMap(item),
        );

        if (itemId <= 0) {
          throw Exception('Failed to insert journal item at index $index');
        }
        entity.items[index] = item.copyWith(id: itemId);
      }
      return entity.copyWith(id: entryId);
    });
  }

  Future<List<JournalItemEntity>> _getJournalItemsByEntryId(int entryId) async {
    final rows = await db.query(
      table: JournalItemsTable().tableName,
      where: '${JournalItemsTable().entryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map(_journalItemFromMap).toList();
  }

  Future<Map<int, List<JournalItemEntity>>> _getJournalItemsByEntryIds(
    List<int> entryIds,
  ) async {
    if (entryIds.isEmpty) return {};

    final where =
        '${JournalItemsTable().entryId} IN (${List.filled(entryIds.length, '?').join(', ')})';
    final rows = await db.query(
      table: JournalItemsTable().tableName,
      where: where,
      whereArgs: entryIds,
    );

    final Map<int, List<JournalItemEntity>> map = {};
    for (final row in rows) {
      final item = _journalItemFromMap(row);
      map.putIfAbsent(item.entryId, () => []).add(item);
    }
    return map;
  }

  @override
  Future<JournalEntryEntity> update(JournalEntryEntity entity) async {
    return await db.transaction(() async {
      await db.update(
        table: JournalEntriesTable().tableName,
        data: toMap(entity),
        where: {JournalEntriesTable().id: entity.id},
      );

      final updatedItems = <JournalItemEntity>[];
      for (var index = 0; index < entity.items.length; index++) {
        final item = entity.items[index].copyWith(entryId: entity.id);
        if (item.id > 0) {
          await db.update(
            table: JournalItemsTable().tableName,
            data: journalItemToMap(item),
            where: {JournalItemsTable().id: item.id},
          );
          updatedItems.add(item);
        } else {
          final itemId = await db.insert(
            table: JournalItemsTable().tableName,
            data: _sanitizeInsertData(
              journalItemToMap(item),
              JournalItemsTable().id,
            ),
          );
          if (itemId <= 0) {
            throw Exception('Failed to insert journal item at index $index');
          }
          updatedItems.add(item.copyWith(id: itemId));
        }
      }

      return entity.copyWith(items: updatedItems);
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await db.transaction(() async {
      await db.deleteWhere(
        table: JournalItemsTable().tableName,
        where: {JournalItemsTable().entryId: id},
      );
      await db.deleteWhere(
        table: JournalEntriesTable().tableName,
        where: {JournalEntriesTable().id: id},
      );
      return true;
    });
  }

  @override
  JournalEntryEntity fromMap(Map<String, dynamic> map) {
    return JournalEntryModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(JournalEntryEntity entity) {
    if (entity is JournalEntryModel) {
      return entity.toMap();
    }
    return JournalEntryModel(
      id: entity.id,
      referenceNumber: entity.referenceNumber,
      description: entity.description,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      currencyId: entity.currencyId,
      baseAmount: entity.baseAmount,
      warehouseId: entity.warehouseId,
      items: entity.items,
    ).toMap();
  }

  JournalItemEntity _journalItemFromMap(Map<String, dynamic> row) {
    return JournalItemModel.fromMap(row);
  }

  @override
  Future<List<JournalEntryEntity>> whereWarehouse(int warehouseId) async {
    final rows = await db.query(
      table: JournalEntriesTable().tableName,
      where: '${JournalEntriesTable().warehouseId} = ?',
      whereArgs: [warehouseId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalEntryEntity>> whereCreatedBy(int userId) async {
    final rows = await db.query(
      table: JournalEntriesTable().tableName,
      where: '${JournalEntriesTable().userId} = ?',
      whereArgs: [userId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<JournalEntryEntity?> firstWhereReferenceNumber(
    String referenceNumber,
  ) async {
    final rows = await db.query(
      table: JournalEntriesTable().tableName,
      where: '${JournalEntriesTable().referenceNumber} = ?',
      whereArgs: [referenceNumber],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  Map<String, dynamic> _sanitizeInsertData(
    Map<String, dynamic> data,
    String idKey,
  ) {
    if (data[idKey] is int && (data[idKey] as int) <= 0) {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized.remove(idKey);
      return sanitized;
    }
    return data;
  }
}
