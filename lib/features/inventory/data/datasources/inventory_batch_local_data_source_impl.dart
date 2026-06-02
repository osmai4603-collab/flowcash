import 'package:flowcash/features/inventory/data/datasources/inventory_batch_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventory_batches_table.dart';
import 'package:flowcash/core/enums/batch_source_enum.dart';
import 'package:flowcash/core/enums/batch_status_enum.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';

final class InventoryBatchLocalDataSourceImpl
    implements InventoryBatchDataSource {
  final SqliteService _db;
  const InventoryBatchLocalDataSourceImpl(this._db);

  @override
  Future<List<InventoryBatchEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: InventoryBatchesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventoryBatchesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoryBatchesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryBatchEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventoryBatchesTable.tableName,
      where: '${InventoryBatchesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryBatchEntity> insert(InventoryBatchEntity entity) async {
    await _db.insert(
      table: InventoryBatchesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), InventoryBatchesTable.id),
    );
    return entity;
  }

  @override
  Future<InventoryBatchEntity> update(InventoryBatchEntity entity) async {
    await _db.update(
      table: InventoryBatchesTable.tableName,
      data: toMap(entity),
      where: {InventoryBatchesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: InventoryBatchesTable.tableName,
      where: {InventoryBatchesTable.id: id},
    );
    return true;
  }

  @override
  InventoryBatchEntity fromMap(Map<String, dynamic> map) {
    return InventoryBatchEntity(
      id: map[InventoryBatchesTable.id] as int,
      batchNumber: (map[InventoryBatchesTable.batchNumber] as String?) ?? "",
      inventoryId: map[InventoryBatchesTable.inventoryId] as int,
      personId: map[InventoryBatchesTable.personId] as int?,
      batchSource: BatchSource.values.firstWhere(
        (e) => e.name == map[InventoryBatchesTable.batchSource] as String,
      ),
      batchStatus: BatchStatus.values.firstWhere(
        (e) => e.name == map[InventoryBatchesTable.batchStatus] as String,
      ),
      countUnits: ((map[InventoryBatchesTable.countUnits]) as num).toDouble(),
      unitCost: ((map[InventoryBatchesTable.unitCost]) as num).toDouble(),
      inputDate: DateTime.parse(map[InventoryBatchesTable.inputDate] as String),
      productionDate: (map[InventoryBatchesTable.productionDate] as String?) != null
          ? DateTime.parse(map[InventoryBatchesTable.productionDate] as String)
          : null,
      expirationDate: (map[InventoryBatchesTable.expirationDate] as String?) != null
          ? DateTime.parse(map[InventoryBatchesTable.expirationDate] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap(InventoryBatchEntity entity) {
    return {
      if (entity.id > 0) InventoryBatchesTable.id: entity.id,
      InventoryBatchesTable.batchNumber: entity.batchNumber,
      InventoryBatchesTable.inventoryId: entity.inventoryId,
      InventoryBatchesTable.personId: entity.personId,
      InventoryBatchesTable.batchSource: entity.batchSource.name,
      InventoryBatchesTable.batchStatus: entity.batchStatus.name,
      InventoryBatchesTable.countUnits: entity.countUnits,
      InventoryBatchesTable.unitCost: entity.unitCost,
      InventoryBatchesTable.inputDate: entity.inputDate.toIso8601String(),
      InventoryBatchesTable.productionDate:
          entity.productionDate?.toIso8601String(),
      InventoryBatchesTable.expirationDate:
          entity.expirationDate?.toIso8601String(),
    };
  }

  @override
  Future<List<InventoryBatchEntity>> whereCategoryIdAndStore(
    Iterable<int> ids, {
    required int storeId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<InventoryBatchEntity>> whereInventory(int inventoryId) async {
    throw UnimplementedError();
  }

  @override
  Future<double> getUnitCost({
    required int inventoryId,
    required InventoryCostType unitCostType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<InventoryBatchEntity?> getBatch({
    required int inventoryId,
    required InventoryCostType unitCostType,
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
