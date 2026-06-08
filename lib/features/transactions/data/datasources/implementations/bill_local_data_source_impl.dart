import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_data_source.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';

final class BillLocalDataSourceImpl implements BillDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(BillOrderEntity) orderToMap;
  const BillLocalDataSourceImpl(this._db, this.orderToMap);

  @override
  Future<List<BillEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: BillsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${BillsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: BillsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<BillEntity?> getById(int id) async {
    final rows = await _db.query(
      table: BillsTable.tableName,
      where: '${BillsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<BillEntity> insert(BillEntity entity) async {
    return await _db.transaction(() async {
      final billId = await _db.insert(
        table: BillsTable.tableName,
        data: _sanitizeInsertData(toMap(entity), BillsTable.id),
      );

      if (billId <= 0) {
        throw Exception('Failed to insert bill');
      }

      for (var index = 0; index < entity.orders.length; index++) {
        entity.orders[index] = entity.orders[index].copyWith(billId: billId);
        final order = entity.orders[index].copyWith(billId: billId);
        final orderId = await _db.insert(
          table: BillOrdersTable.tableName,
          data: _sanitizeInsertData(orderToMap(order), BillOrdersTable.id),
        );

        if (orderId <= 0) {
          throw Exception('Failed to insert bill order at index $index');
        }
        entity.orders[index] = order.copyWith(id: orderId);
      }
      return entity.copyWith(id: billId);
    });
  }

  @override
  Future<BillEntity> update(BillEntity entity) async {
    return await _db.transaction(() async {
      await _db.update(
        table: BillsTable.tableName,
        data: toMap(entity),
        where: {BillsTable.id: entity.id},
      );

      final updatedOrders = <BillOrderEntity>[];
      for (var index = 0; index < entity.orders.length; index++) {
        final order = entity.orders[index].copyWith(billId: entity.id);
        if (order.id > 0) {
          await _db.update(
            table: BillOrdersTable.tableName,
            data: orderToMap(order),
            where: {BillOrdersTable.id: order.id},
          );
          updatedOrders.add(order);
        } else {
          final orderId = await _db.insert(
            table: BillOrdersTable.tableName,
            data: _sanitizeInsertData(orderToMap(order), BillOrdersTable.id),
          );
          if (orderId <= 0) {
            throw Exception('Failed to insert bill order at index $index');
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
        table: BillOrdersTable.tableName,
        where: {BillOrdersTable.billId: id},
      );
      await _db.deleteWhere(
        table: BillsTable.tableName,
        where: {BillsTable.id: id},
      );
      return true;
    });
  }

  @override
  BillEntity fromMap(Map<String, dynamic> map) {
    return BillEntity(
      id: map[BillsTable.id] as int,
      createdAt: DateTime.parse(map[BillsTable.createdAt]),
      createdBy: map[BillsTable.createdBy],
      note: map[BillsTable.note] as String?,
      offerAmount: ((map[BillsTable.offerAmount]) as num).toDouble(),
      currencyId: map[BillsTable.currencyId],
      billNumber: map[BillsTable.billNumber] as int,
      warehouseId: map[BillsTable.warehouseId] as int,
      journalEntryId: map[BillsTable.journalEntryId] as int?,
      personId: map[BillsTable.personId] as int?,
      inventoryTransactionId: map[BillsTable.inventoryTransactionId] as int?,
      isCash: (map[BillsTable.isCash] == true || map[BillsTable.isCash] == 1),
    );
  }

  @override
  Map<String, dynamic> toMap(BillEntity entity) {
    return {
      if (entity.id > 0) BillsTable.id: entity.id,
      BillsTable.createdAt: entity.createdAt.toIso8601String(),
      BillsTable.createdBy: entity.createdBy,
      BillsTable.note: entity.note,
      BillsTable.offerAmount: entity.offerAmount,
      BillsTable.currencyId: entity.currencyId,
      BillsTable.billNumber: entity.billNumber,
      BillsTable.warehouseId: entity.warehouseId,
      BillsTable.journalEntryId: entity.journalEntryId,
      BillsTable.personId: entity.personId,
      BillsTable.inventoryTransactionId: entity.inventoryTransactionId,
      BillsTable.isCash: entity.isCash ? 1 : 0,
    };
  }

  @override
  Future<List<BillEntity>> whereHasNotGoneInStore({
    bool trigger = false,
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
