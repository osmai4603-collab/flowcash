import 'package:flowcash/features/inventory/data/datasources/warehouse_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/data/models/warehouse_model.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/warehouse_values_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';

final class WarehouseLocalDataSourceImpl implements WarehouseDataSource {
  final SqliteService _db;
  const WarehouseLocalDataSourceImpl(this._db);

  @override
  Future<List<WarehouseEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: WarehousesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${WarehousesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: WarehousesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<WarehouseEntity?> getById(int id) async {
    final rows = await _db.query(
      table: WarehousesTable.tableName,
      where: '${WarehousesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<WarehouseEntity> insert(WarehouseEntity entity) async {
    return await _db.transaction(() async {
      final entityId = await _db.insert(
        table: WarehousesTable.tableName,
        data: _sanitizeInsertData(toMap(entity), WarehousesTable.id),
      );
      if (entityId < 0) {
        throw Exception('Failed to insert warehouse');
      }

      final values = WarehouseValueType.values
          .map(
            (valueType) => {
              WarehouseValuesTable.warehouseId: entityId,
              WarehouseValuesTable.valueType: valueType.name,
              WarehouseValuesTable.value: null,
            },
          )
          .toList();

      await _db.insertAll(
         table: WarehouseValuesTable.tableName,
         dataList: values,
      );

      return entity.copyWith(id: entityId);
    });
  }

  @override
  Future<WarehouseEntity> update(WarehouseEntity entity) async {
    await _db.update(
      table: WarehousesTable.tableName,
      data: toMap(entity),
      where: {WarehousesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.transaction(() async {
      await _db.deleteWhere(
        table: WarehouseValuesTable.tableName,
        where: {WarehouseValuesTable.warehouseId: id},
      );

      await _db.deleteWhere(
        table: WarehousesTable.tableName,
        where: {WarehousesTable.id: id},
      );
    });
    return true;
  }

  @override
  Future<List<WarehouseEntity>> getAllStoresWhereWarehouse(
    int warehouseId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: WarehousesTable.tableName,
      where: '${WarehousesTable.id} = ? OR ${WarehousesTable.parentId} = ?',
      whereArgs: [warehouseId, warehouseId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<WarehouseEntity?> getByCode(String code) async {
    final rows = await _db.query(
      table: WarehousesTable.tableName,
      where: '${WarehousesTable.warehouseName} = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  WarehouseEntity fromMap(Map<String, dynamic> map) {
    return WarehouseModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(WarehouseEntity entity) {
    if (entity is WarehouseModel) {
      return entity.toMap();
    }
    return WarehouseModel(
      id: entity.id,
      warehouseName: entity.warehouseName,
      location: entity.location,
      warehouseType: entity.warehouseType,
      parentId: entity.parentId,
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
