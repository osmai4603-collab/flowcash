import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_item_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';

final class JournalItemLocalDataSourceImpl implements JournalItemDataSource {
  final SqliteService _db;
  const JournalItemLocalDataSourceImpl(this._db);

  @override
  Future<List<JournalItemEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: JournalItemsTable.tableName);
      return rows.map(fromMap).toList();
    }

    final where =
        '${JournalItemsTable.itemId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<JournalItemEntity?> getById(int id) async {
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
      where: '${JournalItemsTable.itemId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<JournalItemEntity> insert(JournalItemEntity entity) async {
    final entityId = await _db.insert(
      table: JournalItemsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), JournalItemsTable.itemId),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert journal item');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<JournalItemEntity> update(JournalItemEntity entity) async {
    await _db.update(
      table: JournalItemsTable.tableName,
      data: toMap(entity),
      where: {JournalItemsTable.itemId: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: JournalItemsTable.tableName,
      where: {JournalItemsTable.itemId: id},
    );
    return true;
  }

  @override
  JournalItemEntity fromMap(Map<String, dynamic> map) {
    final statusStr = map[JournalItemsTable.journalStatus] as String?;
    final JournalStatus status;
    if (statusStr != null) {
      status = JournalStatus.of(statusStr);
    } else {
      final debitVal = ((map[JournalItemsTable.debit]) as num?)?.toDouble() ?? 0.0;
      status = debitVal > 0 ? JournalStatus.debit : JournalStatus.credit;
    }
    return JournalItemEntity(
      id: map[JournalItemsTable.itemId] as int,
      entryId: map[JournalItemsTable.entryId] as int,
      accountId: map[JournalItemsTable.accountId] as int,
      debit: ((map[JournalItemsTable.debit]) as num).toDouble(),
      credit: ((map[JournalItemsTable.credit]) as num).toDouble(),
      lineDescription: map[JournalItemsTable.lineDescription] as String?,
      currencyId: map[JournalItemsTable.currencyId] as String,
      exPrice: ((map[JournalItemsTable.exPrice]) as num).toDouble(),
      expriceMain: ((map[JournalItemsTable.expriceMain]) as num).toDouble(),
      journalStatus: status,
    );
  }

  @override
  Map<String, dynamic> toMap(JournalItemEntity entity) {
    return {
      if (entity.id > 0) JournalItemsTable.itemId: entity.id,
      JournalItemsTable.entryId: entity.entryId,
      JournalItemsTable.accountId: entity.accountId,
      JournalItemsTable.debit: entity.debit,
      JournalItemsTable.credit: entity.credit,
      JournalItemsTable.lineDescription: entity.lineDescription,
      JournalItemsTable.currencyId: entity.currencyId,
      JournalItemsTable.exPrice: entity.exPrice,
      JournalItemsTable.expriceMain: entity.expriceMain,
      JournalItemsTable.journalStatus: entity.journalStatus.name,
    };
  }

  @override
  Future<List<JournalItemEntity>> whereEntryId(int entryId) async {
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
      where: '${JournalItemsTable.entryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalItemEntity>> whereAccountId(int accountId) async {
    final rows = await _db.query(
      table: JournalItemsTable.tableName,
      where: '${JournalItemsTable.accountId} = ?',
      whereArgs: [accountId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalItemEntity>> whereWarehouse(int warehouseId) async {
    final db = await _db.database;
    final stmt = db.prepare('''
      SELECT ji.*
      FROM ${JournalItemsTable.tableName} AS ji
      INNER JOIN ${JournalEntriesTable.tableName} AS je
        ON ji.${JournalItemsTable.entryId} = je.${JournalEntriesTable.entryId}
      WHERE je.${JournalEntriesTable.warehouseId} = ?
    ''');
    final result = stmt.select([warehouseId]);
    final items = result
        .map((row) => fromMap(Map<String, dynamic>.from(row)))
        .toList();
    stmt.dispose();
    return items;
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
