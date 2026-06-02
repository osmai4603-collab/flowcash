import 'package:flowcash/features/inventory/data/datasources/warehouse_value_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/core/enums/warehouse_value_type.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/warehouse_values_table.dart';

final class WarehouseValueLocalDataSourceImpl
    implements WarehouseValueDataSource {
  final SqliteService _db;
  const WarehouseValueLocalDataSourceImpl(this._db);

  @override
  Future<List<WarehouseValueEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: WarehouseValuesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${WarehouseValuesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: WarehouseValuesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<WarehouseValueEntity?> getById(int id) async {
    final rows = await _db.query(
      table: WarehouseValuesTable.tableName,
      where: '${WarehouseValuesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<WarehouseValueEntity> insert(WarehouseValueEntity entity) async {
    await _db.insert(
      table: WarehouseValuesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), WarehouseValuesTable.id),
    );
    return entity;
  }

  @override
  Future<WarehouseValueEntity> update(WarehouseValueEntity entity) async {
    await _db.update(
      table: WarehouseValuesTable.tableName,
      data: toMap(entity),
      where: {WarehouseValuesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: WarehouseValuesTable.tableName,
      where: {WarehouseValuesTable.id: id},
    );
    return true;
  }

  @override
  WarehouseValueEntity fromMap(Map<String, dynamic> map) {
    return WarehouseValueEntity(
      id: map[WarehouseValuesTable.id] as int,
      warehouseId: map[WarehouseValuesTable.warehouseId] as int,
      valueType: WarehouseValueType.of(
        map[WarehouseValuesTable.valueType] as String,
      ),
      value: map[WarehouseValuesTable.value],
    );
  }

  @override
  Map<String, dynamic> toMap(WarehouseValueEntity entity) {
    return {
      if (entity.id > 0) WarehouseValuesTable.id: entity.id,
      WarehouseValuesTable.warehouseId: entity.warehouseId,
      WarehouseValuesTable.valueType: entity.valueType.name,
      WarehouseValuesTable.value: entity.value,
    };
  }

  @override
  Future<WarehouseValueEntity?> fetchValue({
    required int warehouseId,
    required WarehouseValueType valueType,
  }) async {
    final rows = await _db.query(
      table: WarehouseValuesTable.tableName,
      where:
          '${WarehouseValuesTable.warehouseId} = ? AND ${WarehouseValuesTable.valueType} = ?',
      whereArgs: [warehouseId, valueType.name],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<int> fetchDefaultSalesAccount({required int warehouseId}) async {
    final value = await fetchValue(
      warehouseId: warehouseId,
      valueType: WarehouseValueType.defaultSalesAccount,
    );
    if (value?.value == null) {
      throw 'No Object Value For ${WarehouseValueType.defaultSalesAccount.name.toUpperCase()}';
    }
    if (value!.value.toString().isEmpty) {
      throw 'No Object Value For ${WarehouseValueType.defaultSalesAccount.name.toUpperCase()}';
    }
    return value.value as int;
  }

  @override
  Future<int> fetchDefaultSalesReturnAccount({required int warehouseId}) async {
    final value = await fetchValue(
      warehouseId: warehouseId,
      valueType: WarehouseValueType.defaultBackSalesAccount,
    );
    if (value?.value == null) {
      throw 'No Object Value For ${WarehouseValueType.defaultBackSalesAccount.name.toUpperCase()}';
    }
    if (value!.value.toString().isEmpty) {
      throw 'No Object Value For ${WarehouseValueType.defaultBackSalesAccount.name.toUpperCase()}';
    }
    return value.value as int;
  }

  @override
  Future<int> fetchDefaultBuysAccount({required int warehouseId}) async {
    final value = await fetchValue(
      warehouseId: warehouseId,
      valueType: WarehouseValueType.defaultBuysAccount,
    );
    if (value?.value == null) {
      throw 'No Object Value For ${WarehouseValueType.defaultBuysAccount.name.toUpperCase()}';
    }
    if (value!.value.toString().isEmpty) {
      throw 'No Object Value For ${WarehouseValueType.defaultBuysAccount.name.toUpperCase()}';
    }
    return value.value as int;
  }

  @override
  Future<int> fetchDefaultBuysReturnAccount({required int warehouseId}) async {
    final value = await fetchValue(
      warehouseId: warehouseId,
      valueType: WarehouseValueType.defaultBackBuysAccount,
    );
    if (value?.value == null) {
      throw 'No Object Value For ${WarehouseValueType.defaultBackBuysAccount.name.toUpperCase()}';
    }
    if (value!.value.toString().isEmpty) {
      throw 'No Object Value For ${WarehouseValueType.defaultBackBuysAccount.name.toUpperCase()}';
    }
    return value.value as int;
  }

  @override
  Future<Map<WarehouseValueType, WarehouseValueEntity>> fetchAsMap() async {
    final list = await get();
    return {for (var v in list) v.valueType: v};
  }

  @override
  Future<bool> updateValue({required String? value, required int id}) async {
    try {
      await _db.update(
        table: WarehouseValuesTable.tableName,
        data: {WarehouseValuesTable.value: value},
        where: {WarehouseValuesTable.id: id},
      );
      return true;
    } catch (_) {
      return false;
    }
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
