import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';

final class InventoryTransactionLocalDataSourceImpl
    implements InventoryTransactionDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(InventoryTransactionOrderEntity) orderToMap;
  const InventoryTransactionLocalDataSourceImpl(this._db, this.orderToMap);

  @override
  Future<List<InventoryTransactionEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: InventoryTransactionsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventoryTransactionsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoryTransactionsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryTransactionEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventoryTransactionsTable.tableName,
      where: '${InventoryTransactionsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryTransactionEntity> insert(InventoryTransactionEntity entity) async {
    return await _db.transaction(() async {
      final transactionId = await _db.insert(
        table: InventoryTransactionsTable.tableName,
        data: _sanitizeInsertData(toMap(entity), InventoryTransactionsTable.id),
      );

      if (transactionId <= 0) {
        throw Exception('Failed to insert inventory transaction');
      }

      for (var index = 0; index < entity.orders.length; index++) {
        final order = entity.orders[index].copyWith(tranId: transactionId);
        final orderId = await _db.insert(
          table: InventoryTransactionsOrdersTable.tableName,
          data: _sanitizeInsertData(orderToMap(order), InventoryTransactionsOrdersTable.id),
        );

        if (orderId <= 0) {
          throw Exception(
            'Failed to insert inventory transaction order at index $index',
          );
        }
        entity.orders[index] = order.copyWith(id: orderId);
      }
      return entity.copyWith(id: transactionId);
    });
  }

  @override
  Future<InventoryTransactionEntity> update(InventoryTransactionEntity entity) async {
    return await _db.transaction(() async {
      await _db.update(
        table: InventoryTransactionsTable.tableName,
        data: toMap(entity),
        where: {InventoryTransactionsTable.id: entity.id},
      );

      final updatedOrders = <InventoryTransactionOrderEntity>[];
      for (var index = 0; index < entity.orders.length; index++) {
        final order = entity.orders[index].copyWith(tranId: entity.id);
        if (order.id > 0) {
          await _db.update(
            table: InventoryTransactionsOrdersTable.tableName,
            data: orderToMap(order),
            where: {InventoryTransactionsOrdersTable.id: order.id},
          );
          updatedOrders.add(order);
        } else {
          final orderId = await _db.insert(
            table: InventoryTransactionsOrdersTable.tableName,
            data: _sanitizeInsertData(orderToMap(order), InventoryTransactionsOrdersTable.id),
          );
          if (orderId <= 0) {
            throw Exception('Failed to insert inventory transaction order at index $index');
          }
          updatedOrders.add(order.copyWith(id: orderId));
        }
      }

      return entity.copyWith(orders: updatedOrders);
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: InventoryTransactionsOrdersTable.tableName,
        where: {InventoryTransactionsOrdersTable.tranId: id},
      );
      await _db.deleteWhere(
        table: InventoryTransactionsTable.tableName,
        where: {InventoryTransactionsTable.id: id},
      );
      return true;
    });
  }

  @override
  InventoryTransactionEntity fromMap(Map<String, dynamic> map) {
    return InventoryTransactionEntity(
      id: map[InventoryTransactionsTable.id] as int,
      createdAt: DateTime.parse(
        map[InventoryTransactionsTable.createdAt] as String? ?? "",
      ),
      createdBy: map[InventoryTransactionsTable.createdBy],
      note: map[InventoryTransactionsTable.note] as String?,
      warehouseId: map[InventoryTransactionsTable.warehouseId] as int,
      personId: map[InventoryTransactionsTable.personId] as int,
      billNumber: map[InventoryTransactionsTable.billNumber] as int,
      transactionType: InventoryTransactionType.values.firstWhere(
        (e) =>
            e.name == map[InventoryTransactionsTable.transactionType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(InventoryTransactionEntity entity) {
    return {
      if (entity.id > 0) InventoryTransactionsTable.id: entity.id,
      InventoryTransactionsTable.createdAt: entity.createdAt.toIso8601String(),
      InventoryTransactionsTable.createdBy: entity.createdBy,
      InventoryTransactionsTable.note: entity.note,
      InventoryTransactionsTable.warehouseId: entity.warehouseId,
      InventoryTransactionsTable.personId: entity.personId,
      InventoryTransactionsTable.billNumber: entity.billNumber,
      InventoryTransactionsTable.transactionType: entity.transactionType.name,
    };
  }


  @override
  Future<List<InventoryTransactionEntity>> whereStoreId(
    Iterable<int> ids,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, InventoryTransactionEntity>> whereStoreToMap(
    int storeId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<InventoryTransactionEntity>> wherePersonId(
    Iterable<int> ids,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<InventoryTransactionEntity>> whereStoreIdAndPersonId({
    required Iterable<int> storesIds,
    required Iterable<int> personsIds,
    bool trigger = false,
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> getIdsWhereStore(
    int storeId, {
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
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
