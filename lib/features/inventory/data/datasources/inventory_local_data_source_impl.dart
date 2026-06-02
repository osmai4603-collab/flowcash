import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';

final class InventoryLocalDataSourceImpl implements InventoryDataSource {
  final SqliteService _db;
  const InventoryLocalDataSourceImpl(this._db);

  @override
  Future<List<InventoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: InventoriesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventoriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventoriesTable.tableName,
      where: '${InventoriesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryEntity> insert(InventoryEntity entity) async {
    await _db.insert(
      table: InventoriesTable.tableName,
      data: toMap(entity),
    );
    return entity;
  }

  @override
  Future<InventoryEntity> update(InventoryEntity entity) async {
    await _db.update(
      table: InventoriesTable.tableName,
      data: toMap(entity),
      where: {InventoriesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: InventoriesTable.tableName,
      where: {InventoriesTable.id: id},
    );
    return true;
  }

  @override
  InventoryEntity fromMap(Map<String, dynamic> map) {
    return _InventoryLocalEntity(
      id: map[InventoriesTable.id] as int,
      categoryId: map[InventoriesTable.categoryId] as int,
      storeId: map[InventoriesTable.storeId] as int,
      costType: InventoryCostType.values.firstWhere(
        (e) => e.name == map[InventoriesTable.costType] as String,
      ),
      revenueAccountId: map[InventoriesTable.revenueAccountId] as int?,
      expenseAccountId: map[InventoriesTable.expenseAccountId] as int?,
      incomeStockId: map[InventoriesTable.incomeStockId] as int?,
      outcomeStockId: map[InventoriesTable.outcomeStockId] as int?,
      countUnits: ((map[InventoriesTable.countUnits]) as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap(InventoryEntity entity) {
    return {
      if (entity.id > 0) InventoriesTable.id: entity.id,
      InventoriesTable.categoryId: entity.categoryId,
      InventoriesTable.storeId: entity.storeId,
      InventoriesTable.costType: entity.costType.name,
      InventoriesTable.revenueAccountId: entity.revenueAccountId,
      InventoriesTable.expenseAccountId: entity.expenseAccountId,
      InventoriesTable.incomeStockId: entity.incomeStockId,
      InventoriesTable.outcomeStockId: entity.outcomeStockId,
      InventoriesTable.countUnits: entity.countUnits,
    };
  }

  @override
  Future<List<InventoryEntity>> whereStore(
    int storeId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: InventoriesTable.tableName,
      where: '${InventoriesTable.storeId} = ?',
      whereArgs: [storeId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryEntity?> firstWhereCategory(
    int categoryId,
    int storeId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: InventoriesTable.tableName,
      where:
          '${InventoriesTable.categoryId} = ? AND ${InventoriesTable.storeId} = ? LIMIT 1',
      whereArgs: [categoryId, storeId],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryEntity?> firstWhereCategoryAndStore(
    int categoryId,
    int storeId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    return await firstWhereCategory(
      categoryId,
      storeId,
      trigger: trigger,
      printQuery: printQuery,
    );
  }

  @override
  Future<List<InventoryEntity>> whereCategories(
    Iterable<int> ids, {
    required int storeId,
    bool trigger = false,
    bool printQuery = true,
  }) async {
    if (ids.isEmpty) return [];
    final where =
        '${InventoriesTable.storeId} = ? AND ${InventoriesTable.categoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoriesTable.tableName,
      where: where,
      whereArgs: [storeId, ...ids.toList()],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryEntity> getInventory({
    required int categoryId,
    required int warehouseId,
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final result = await firstWhereCategoryAndStore(
      categoryId,
      warehouseId,
      trigger: trigger,
      printQuery: printQuery,
    );
    if (result == null) {
      throw 'Inventory not found for categoryId: $categoryId and warehouseId: $warehouseId';
    }
    return result;
  }
}

final class _InventoryLocalEntity extends InventoryEntity {
  const _InventoryLocalEntity({
    required super.id,
    required super.categoryId,
    required super.storeId,
    required super.costType,
    super.revenueAccountId,
    super.expenseAccountId,
    super.incomeStockId,
    super.outcomeStockId,
    required super.countUnits,
  });

  @override
  _InventoryLocalEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    InventoryCostType? costType,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    double? countUnits,
  }) {
    return _InventoryLocalEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      costType: costType ?? this.costType,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
      countUnits: countUnits ?? this.countUnits,
    );
  }

}
