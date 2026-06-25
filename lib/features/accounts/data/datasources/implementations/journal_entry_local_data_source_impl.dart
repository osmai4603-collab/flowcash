import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/data/models/journal_entry_model.dart';
import 'package:flowcash/features/accounts/data/models/journal_item_model.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';

final class JournalEntryLocalDataSourceImpl implements JournalEntryDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(JournalItemEntity) journalItemToMap;
  const JournalEntryLocalDataSourceImpl(this._db, this.journalItemToMap);

  @override
  Future<List<JournalEntryEntity>> get({
    Iterable<int>? ids,
    bool getItems = false,
  }) async {
    final rows = ids == null
        ? await _db.query(table: JournalEntriesTable.tableName)
        : await _db.query(
            table: JournalEntriesTable.tableName,
            where:
                '${JournalEntriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})',
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
    final rows = await _db.query(
      table: JournalEntriesTable.tableName,
      where: '${JournalEntriesTable.id} = ?',
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
    return await _db.transaction(() async {
      final entryId = await _db.insert(
        table: JournalEntriesTable.tableName,
        data: toMap(entity),
      );

      if (entryId <= 0) {
        throw Exception('Failed to insert journal entry');
      }

      for (var index = 0; index < entity.items.length; index++) {
        final item = entity.items[index].copyWith(entryId: entryId);
        final itemId = await _db.insert(
          table: JournalItemsTable.tableName,
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

  @override
  Future<JournalEntryEntity> saveWithItems(
    JournalEntryEntity entry,
    List<JournalItemEntity> items,
  ) async {
    final db = await _db.database;
    db.execute('BEGIN');

    try {
      JournalEntryEntity persistedEntry = entry;

      if (entry.id > 0) {
        final updateData = Map<String, dynamic>.from(toMap(entry))
          ..remove(JournalEntriesTable.id);
        final setClause = updateData.keys.map((key) => '$key = ?').join(', ');
        final updateStmt = db.prepare(
          'UPDATE ${JournalEntriesTable.tableName} SET $setClause WHERE ${JournalEntriesTable.id} = ?',
        );
        updateStmt.execute([...updateData.values, entry.id]);
        updateStmt.dispose();

        final deleteStmt = db.prepare(
          'DELETE FROM ${JournalItemsTable.tableName} WHERE ${JournalItemsTable.entryId} = ?',
        );
        deleteStmt.execute([entry.id]);
        deleteStmt.dispose();
      } else {
        final insertData = toMap(entry);
        final columns = insertData.keys.join(', ');
        final placeholders = List.filled(insertData.length, '?').join(', ');
        final insertStmt = db.prepare(
          'INSERT INTO ${JournalEntriesTable.tableName} ($columns) VALUES ($placeholders)',
        );
        insertStmt.execute(insertData.values.toList());
        final id = db.lastInsertRowId;
        insertStmt.dispose();
        persistedEntry = entry.copyWith(id: id);
      }

      for (final item in items) {
        final sanitizedItem = journalItemToMap(
          item.copyWith(entryId: persistedEntry.id),
        );
        final columns = sanitizedItem.keys.join(', ');
        final placeholders = List.filled(sanitizedItem.length, '?').join(', ');
        final itemInsertStmt = db.prepare(
          'INSERT INTO ${JournalItemsTable.tableName} ($columns) VALUES ($placeholders)',
        );
        itemInsertStmt.execute(sanitizedItem.values.toList());
        itemInsertStmt.dispose();
      }

      db.execute('COMMIT');
      return persistedEntry;
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<List<JournalItemEntity>> _getJournalItemsByEntryId(int entryId) async {
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
      where: '${JournalItemsTable.entryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map(_journalItemFromMap).toList();
  }

  Future<Map<int, List<JournalItemEntity>>> _getJournalItemsByEntryIds(
    List<int> entryIds,
  ) async {
    if (entryIds.isEmpty) return {};

    final where =
        '${JournalItemsTable.entryId} IN (${List.filled(entryIds.length, '?').join(', ')})';
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
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
    return await _db.transaction(() async {
      await _db.update(
        table: JournalEntriesTable.tableName,
        data: toMap(entity),
        where: {JournalEntriesTable.id: entity.id},
      );

      final updatedItems = <JournalItemEntity>[];
      for (var index = 0; index < entity.items.length; index++) {
        final item = entity.items[index].copyWith(entryId: entity.id);
        if (item.id > 0) {
          await _db.update(
            table: JournalItemsTable.tableName,
            data: journalItemToMap(item),
            where: {JournalItemsTable.itemId: item.id},
          );
          updatedItems.add(item);
        } else {
          final itemId = await _db.insert(
            table: JournalItemsTable.tableName,
            data: _sanitizeInsertData(
              journalItemToMap(item),
              JournalItemsTable.itemId,
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
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: JournalItemsTable.tableName,
        where: {JournalItemsTable.entryId: id},
      );
      await _db.deleteWhere(
        table: JournalEntriesTable.tableName,
        where: {JournalEntriesTable.id: id},
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
    final rows = await _db.query(
      table: JournalEntriesTable.tableName,
      where: '${JournalEntriesTable.warehouseId} = ?',
      whereArgs: [warehouseId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalEntryEntity>> whereCreatedBy(int userId) async {
    final rows = await _db.query(
      table: JournalEntriesTable.tableName,
      where: '${JournalEntriesTable.userId} = ?',
      whereArgs: [userId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<JournalEntryEntity?> firstWhereReferenceNumber(
    String referenceNumber,
  ) async {
    final rows = await _db.query(
      table: JournalEntriesTable.tableName,
      where: '${JournalEntriesTable.referenceNumber} = ?',
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
