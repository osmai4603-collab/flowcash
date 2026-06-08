import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_order_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';

final class InventoryTransactionOrderLocalDataSourceImpl
    implements InventoryTransactionOrderDataSource {
  final SqliteService _db;
  const InventoryTransactionOrderLocalDataSourceImpl(this._db);

  @override
  Future<List<InventoryTransactionOrderEntity>> get({
    Iterable<int>? ids,
  }) async {
    if (ids == null) {
      final rows = await _db.query(
        table: InventoryTransactionsOrdersTable.tableName,
      );
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventoryTransactionsOrdersTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoryTransactionsOrdersTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryTransactionOrderEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventoryTransactionsOrdersTable.tableName,
      where: '${InventoryTransactionsOrdersTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryTransactionOrderEntity> insert(
    InventoryTransactionOrderEntity entity,
  ) async {
    final entityId = await _db.insert(
      table: InventoryTransactionsOrdersTable.tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert value');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<InventoryTransactionOrderEntity> update(
    InventoryTransactionOrderEntity entity,
  ) async {
    await _db.update(
      table: InventoryTransactionsOrdersTable.tableName,
      data: toMap(entity),
      where: {InventoryTransactionsOrdersTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: InventoryTransactionsOrdersTable.tableName,
      where: {InventoryTransactionsOrdersTable.id: id},
    );
    return true;
  }

  @override
  InventoryTransactionOrderEntity fromMap(Map<String, dynamic> map) {
    return InventoryTransactionOrderEntity(
      id: map[InventoryTransactionsOrdersTable.id] as int,
      inventoryId: map[InventoryTransactionsOrdersTable.inventoryId] as int?,
      countUnits: ((map[InventoryTransactionsOrdersTable.countUnits]) as num)
          .toDouble(),
      tranId: map[InventoryTransactionsOrdersTable.tranId] as int,
      transactionType: InventoryTransactionType.values.firstWhere(
        (e) =>
            e.name ==
            map[InventoryTransactionsOrdersTable.transactionType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(InventoryTransactionOrderEntity entity) {
    return {
      if (entity.id > 0) InventoryTransactionsOrdersTable.id: entity.id,
      InventoryTransactionsOrdersTable.inventoryId: entity.inventoryId,
      InventoryTransactionsOrdersTable.countUnits: entity.countUnits,
      InventoryTransactionsOrdersTable.tranId: entity.tranId,
      InventoryTransactionsOrdersTable.transactionType:
          entity.transactionType.name,
    };
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
