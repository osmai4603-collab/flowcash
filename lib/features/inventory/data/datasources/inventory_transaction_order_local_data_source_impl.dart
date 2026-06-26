import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_order_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/data/models/inventory_transaction_order_model.dart';
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
    return InventoryTransactionOrderModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(InventoryTransactionOrderEntity entity) {
    if (entity is InventoryTransactionOrderModel) {
      return entity.toMap();
    }
    return InventoryTransactionOrderModel(
      id: entity.id,
      inventoryId: entity.inventoryId,
      countUnits: entity.countUnits,
      tranId: entity.tranId,
    ).toMap();
  }
}
