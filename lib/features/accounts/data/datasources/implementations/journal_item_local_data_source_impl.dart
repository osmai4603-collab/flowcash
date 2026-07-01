import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_item_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/data/models/journal_item_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';

final class JournalItemLocalDataSourceImpl implements JournalItemDataSource {
  final SqliteDatabase _db;
  const JournalItemLocalDataSourceImpl(this._db);

  @override
  Future<List<JournalItemEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: JournalItemsTable().tableName);
      return rows.map(fromMap).toList();
    }

    final where =
        '${JournalItemsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: JournalItemsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<JournalItemEntity?> getById(int id) async {
    final rows = await _db.query(
      table: JournalItemsTable().tableName,
      where: '${JournalItemsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<JournalItemEntity> insert(JournalItemEntity entity) async {
    final entityId = await _db.insert(
      table: JournalItemsTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert journal item');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<JournalItemEntity> update(JournalItemEntity entity) async {
    await _db.update(
      table: JournalItemsTable().tableName,
      data: toMap(entity),
      where: {JournalItemsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: JournalItemsTable().tableName,
      where: {JournalItemsTable().id: id},
    );
    return true;
  }

  @override
  JournalItemEntity fromMap(Map<String, dynamic> map) {
    return JournalItemModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(JournalItemEntity entity) {
    if (entity is JournalItemModel) {
      return entity.toMap();
    }
    return JournalItemModel(
      id: entity.id,
      entryId: entity.entryId,
      accountId: entity.accountId,
      amount: entity.amount,
      lineDescription: entity.lineDescription,
      currencyId: entity.currencyId,
      exPrice: entity.exPrice,
      exPriceMain: entity.exPriceMain,
      journalStatus: entity.journalStatus,
    ).toMap();
  }

  @override
  Future<List<JournalItemEntity>> whereEntryId(int entryId) async {
    final rows = await _db.query(
      table: JournalItemsTable().tableName,
      where: '${JournalItemsTable().entryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalItemEntity>> whereAccountId(int accountId) async {
    final rows = await _db.query(
      table: JournalItemsTable().tableName,
      where: '${JournalItemsTable().accountId} = ?',
      whereArgs: [accountId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<JournalItemEntity>> whereWarehouse(int warehouseId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT ji.*
      FROM ${JournalItemsTable().tableName} AS ji
      INNER JOIN ${JournalEntriesTable().tableName} AS je
        ON ji.${JournalItemsTable().entryId} = je.${JournalEntriesTable().id}
      WHERE je.${JournalEntriesTable().warehouseId} = ?
      ''',
      [warehouseId],
    );
    return rows.map((row) => fromMap(Map<String, dynamic>.from(row))).toList();
  }

}
