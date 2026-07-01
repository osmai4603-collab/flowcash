import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/cost_good_bill_data_source.dart';
import 'package:flowcash/features/transactions/data/models/cost_good_bill_model.dart';
import 'package:flowcash/features/transactions/data/models/cost_good_bill_order_model.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';

final class CostGoodBillLocalDataSourceImpl implements CostGoodBillDataSource {
  final SqliteDatabase _db;
  final Map<String, dynamic> Function(CostGoodBillOrderEntity) orderToMap;

  const CostGoodBillLocalDataSourceImpl(this._db, this.orderToMap);

  @override
  Future<List<CostGoodBillEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: CostGoodBillsTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${CostGoodBillsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CostGoodBillsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<CostGoodBillEntity?> getById(int id) async {
    final rows = await _db.query(
      table: CostGoodBillsTable().tableName,
      where: '${CostGoodBillsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    
    // Fetch orders
    final orderRows = await _db.query(
      table: CostGoodBillOrdersTable().tableName,
      where: '${CostGoodBillOrdersTable().billId} = ?',
      whereArgs: [id],
    );
    final orders = orderRows.map((r) => CostGoodBillOrderModel.fromMap(r)).toList();

    return CostGoodBillModel.fromMap(rows.first, orders: orders);
  }

  @override
  Future<CostGoodBillEntity> insert(CostGoodBillEntity entity) async {
    return await _db.transaction(() async {
      final data = toMap(entity);
      final costGoodBillId = await _db.insert(
        table: CostGoodBillsTable().tableName,
        data: _sanitizeInsertData(data, CostGoodBillsTable().id),
      );

      if (costGoodBillId <= 0) {
        throw Exception('Failed to insert cost good bill');
      }

      final insertedOrders = <CostGoodBillOrderEntity>[];
      for (var index = 0; index < entity.orders.length; index++) {
        final order = entity.orders[index].copyWith(costGoodBillId: costGoodBillId);
        final orderData = orderToMap(order);
        final orderId = await _db.insert(
          table: CostGoodBillOrdersTable().tableName,
          data: _sanitizeInsertData(orderData, CostGoodBillOrdersTable().id),
        );

        if (orderId <= 0) {
          throw Exception('Failed to insert cost good bill order at index $index');
        }
        insertedOrders.add(order.copyWith(id: orderId));
      }
      return entity.copyWith(id: costGoodBillId, orders: insertedOrders);
    });
  }

  @override
  Future<CostGoodBillEntity> update(CostGoodBillEntity entity) async {
    return await _db.transaction(() async {
      await _db.update(
        table: CostGoodBillsTable().tableName,
        data: toMap(entity),
        where: {CostGoodBillsTable().id: entity.id},
      );

      final updatedOrders = <CostGoodBillOrderEntity>[];
      for (var index = 0; index < entity.orders.length; index++) {
        final order = entity.orders[index].copyWith(costGoodBillId: entity.id);
        if (order.id > 0) {
          await _db.update(
            table: CostGoodBillOrdersTable().tableName,
            data: orderToMap(order),
            where: {CostGoodBillOrdersTable().id: order.id},
          );
          updatedOrders.add(order);
        } else {
          final orderId = await _db.insert(
            table: CostGoodBillOrdersTable().tableName,
            data: _sanitizeInsertData(orderToMap(order), CostGoodBillOrdersTable().id),
          );
          if (orderId <= 0) {
            throw Exception('Failed to insert cost good bill order at index $index');
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
        table: CostGoodBillOrdersTable().tableName,
        where: {CostGoodBillOrdersTable().billId: id},
      );
      await _db.deleteWhere(
        table: CostGoodBillsTable().tableName,
        where: {CostGoodBillsTable().id: id},
      );
      return true;
    });
  }

  @override
  CostGoodBillEntity fromMap(Map<String, dynamic> map) {
    return CostGoodBillModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(CostGoodBillEntity entity) {
    if (entity is CostGoodBillModel) {
      return entity.toMap();
    }
    return CostGoodBillModel(
      id: entity.id,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      note: entity.note,
      offerAmount: entity.offerAmount,
      currencyId: entity.currencyId,
      billNumber: entity.billNumber,
      warehouseId: entity.warehouseId,
      journalEntryId: entity.journalEntryId,
      personId: entity.personId,
      billId: entity.billId,
      orders: entity.orders,
    ).toMap();
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
