import 'package:flowcash/features/inventory/data/datasources/opening_quantity_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

final class OpeningQuantityLocalDataSourceImpl
    implements OpeningQuantityDataSource {
  final SqliteService _db;
  const OpeningQuantityLocalDataSourceImpl(this._db);

  @override
  Future<List<OpeningQuantityEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: OpeningQuantitiesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${OpeningQuantitiesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: OpeningQuantitiesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<OpeningQuantityEntity?> getById(int id) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable.tableName,
      where: '${OpeningQuantitiesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<OpeningQuantityEntity> insert(OpeningQuantityEntity entity) async {
    final entityId = await _db.insert(
      table: OpeningQuantitiesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), OpeningQuantitiesTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert opening quantity');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<OpeningQuantityEntity> update(OpeningQuantityEntity entity) async {
    await _db.update(
      table: OpeningQuantitiesTable.tableName,
      data: toMap(entity),
      where: {OpeningQuantitiesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: OpeningQuantitiesTable.tableName,
      where: {OpeningQuantitiesTable.id: id},
    );
    return true;
  }

  @override
  OpeningQuantityEntity fromMap(Map<String, dynamic> map) {
    return OpeningQuantityEntity(
      id: map[OpeningQuantitiesTable.id] as int,
      categoryId: map[OpeningQuantitiesTable.categoryId] as int,
      countUnits: ((map[OpeningQuantitiesTable.countUnits]) as num).toDouble(),
      warehouseId: map[OpeningQuantitiesTable.warehouseId] as int,
      createdAt: DateTime.parse(
        map[OpeningQuantitiesTable.createdAt] as String? ?? "",
      ),
      costTotal: ((map[OpeningQuantitiesTable.costTotal]) as num).toDouble(),
      periodId: map[OpeningQuantitiesTable.periodId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(OpeningQuantityEntity entity) {
    return {
      if (entity.id > 0) OpeningQuantitiesTable.id: entity.id,
      OpeningQuantitiesTable.categoryId: entity.categoryId,
      OpeningQuantitiesTable.countUnits: entity.countUnits,
      OpeningQuantitiesTable.warehouseId: entity.warehouseId,
      OpeningQuantitiesTable.createdAt: entity.createdAt.toIso8601String(),
      OpeningQuantitiesTable.costTotal: entity.costTotal,
      OpeningQuantitiesTable.periodId: entity.periodId,
    };
  }

  @override
  Future<OpeningQuantityEntity?> getOpeningQuantity({
    required int storeId,
    required int categoryId,
    bool trigger = false,
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<double> getSumUnitsWhereStoreAndCategory(
    int storeId,
    int categoryId, {
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<OpeningQuantityEntity>> whereCommodity(
    InventoryEntity commodity, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<OpeningQuantityEntity>> whereStore(
    int storeId, {
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
