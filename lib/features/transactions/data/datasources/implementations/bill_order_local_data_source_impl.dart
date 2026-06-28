import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_order_data_source.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

final class BillOrderLocalDataSourceImpl implements BillOrderDataSource {
  final SqliteService _db;
  const BillOrderLocalDataSourceImpl(this._db);

  @override
  Future<List<BillOrderEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: BillOrdersTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${BillOrdersTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: BillOrdersTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<BillOrderEntity?> getById(int id) async {
    final rows = await _db.query(
      table: BillOrdersTable().tableName,
      where: '${BillOrdersTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<BillOrderEntity> insert(BillOrderEntity entity) async {
    final entityId = await _db.insert(
      table: BillOrdersTable().tableName,
      data: _sanitizeInsertData(toMap(entity), BillOrdersTable().id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert bill order');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<BillOrderEntity> update(BillOrderEntity entity) async {
    await _db.update(
      table: BillOrdersTable().tableName,
      data: toMap(entity),
      where: {BillOrdersTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: BillOrdersTable().tableName,
      where: {BillOrdersTable().id: id},
    );
    return true;
  }

  @override
  BillOrderEntity fromMap(Map<String, dynamic> map) {
    return BillOrderEntity(
      id: map[BillOrdersTable().id] as int,
      billId: map[BillOrdersTable().billId] as int,
      categoryId: map[BillOrdersTable().categoryId] as int,
      countUnits: ((map[BillOrdersTable().countUnits]) as num).toDouble(),
      totalPrice: ((map[BillOrdersTable().totalPrice]) as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap(BillOrderEntity entity) {
    return {
      if (entity.id > 0) BillOrdersTable().id: entity.id,
      BillOrdersTable().billId: entity.billId,
      BillOrdersTable().categoryId: entity.categoryId,
      BillOrdersTable().countUnits: entity.countUnits,
      BillOrdersTable().totalPrice: entity.totalPrice,
    };
  }

  @override
  Future<List<BillOrderEntity>> whereBillId(Iterable<int> ids) async {
    if (ids.isEmpty) return [];
    final where =
        '${BillOrdersTable().billId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: BillOrdersTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<double> getSumUnitWhereOrder(int categoryId, int storeId) async {
    final query = '''
      SELECT SUM(bo.${BillOrdersTable().countUnits}) as total
      FROM ${BillOrdersTable().tableName} bo
      INNER JOIN ${BillsTable().tableName} b ON bo.${BillOrdersTable().billId} = b.${BillsTable().id}
      WHERE bo.${BillOrdersTable().categoryId} = ? AND b.${BillsTable().warehouseId} = ?
    ''';
    final result = await _db.rawQuery(query, [categoryId, storeId]);
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  @override
  Future<BillOrderEntity?> firstWhereCategoryId(int categoryId) async {
    final rows = await _db.query(
      table: BillOrdersTable().tableName,
      where: '${BillOrdersTable().categoryId} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<List<BillOrderEntity>> whereBatchId(Iterable<int> ids) async {
    if (ids.isEmpty) return [];
    final where =
        '${BillOrdersTable().billId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: BillOrdersTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<BillOrderEntity>> whereInventory(int inventoryId) async {
    final inventoryRows = await _db.query(
      table: InventoriesTable().tableName,
      where: '${InventoriesTable().id} = ?',
      whereArgs: [inventoryId],
      limit: 1,
    );
    if (inventoryRows.isEmpty) return [];
    final categoryId = inventoryRows.first[InventoriesTable().categoryId] as int;
    final storeId = inventoryRows.first[InventoriesTable().storeId] as int;

    final query = '''
      SELECT bo.*
      FROM ${BillOrdersTable().tableName} bo
      INNER JOIN ${BillsTable().tableName} b ON bo.${BillOrdersTable().billId} = b.${BillsTable().id}
      WHERE bo.${BillOrdersTable().categoryId} = ? AND b.${BillsTable().warehouseId} = ?
    ''';
    final rows = await _db.rawQuery(query, [categoryId, storeId]);
    return rows.map(fromMap).toList();
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
