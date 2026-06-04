import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_category_entity.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

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
    final entityId = await _db.insert(
      table: InventoriesTable.tableName,
      data: toMap(entity),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert inventory');
    }
    return entity.copyWith(id: entityId);
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
      revenueAccountId: map[InventoriesTable.revenueAccountId] as int?,
      expenseAccountId: map[InventoriesTable.expenseAccountId] as int?,
      incomeStockId: map[InventoriesTable.incomeStockId] as int?,
      outcomeStockId: map[InventoriesTable.outcomeStockId] as int?,
      inventoryName: '',
      unitCost: ((map[InventoriesTable.unitCost] ?? 0) as num).toDouble(),
      countUnits: ((map[InventoriesTable.countUnits]) as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap(InventoryEntity entity) {
    return {
      if (entity.id > 0) InventoriesTable.id: entity.id,
      InventoriesTable.categoryId: entity.categoryId,
      InventoriesTable.storeId: entity.storeId,
      InventoriesTable.revenueAccountId: entity.revenueAccountId,
      InventoriesTable.expenseAccountId: entity.expenseAccountId,
      InventoriesTable.incomeStockId: entity.incomeStockId,
      InventoriesTable.outcomeStockId: entity.outcomeStockId,
      InventoriesTable.unitCost: entity.unitCost,
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
      whereArgs: [storeId, ...ids],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<InventoryCategoryEntity>> getInventoryCategories({
    int? warehouseId,
  }) async {
    // Build base query with JOIN to categories
    final buffer = StringBuffer();
    buffer.write('SELECT i.${InventoriesTable.id} AS inventory_id, i.${InventoriesTable.categoryId} AS category_id, i.${InventoriesTable.storeId} AS store_id, i.${InventoriesTable.revenueAccountId} AS revenue_id, i.${InventoriesTable.expenseAccountId} AS expense_id, i.${InventoriesTable.incomeStockId} AS income_stock_id, i.${InventoriesTable.outcomeStockId} AS outcome_stock_id, i.${InventoriesTable.unitCost} AS unit_cost, i.${InventoriesTable.countUnits} AS count_units, c.${CategoriesTable.categoryName} AS category_name, c.${CategoriesTable.categoryUnitId} AS category_unit_id, u.${UnitsTable.unitName} AS unit_name, u.${UnitsTable.length} AS unit_length, u.${UnitsTable.width} AS unit_width, u.${UnitsTable.thickness} AS unit_thickness, u.${UnitsTable.unitType} AS unit_type');
    buffer.write(' FROM ${InventoriesTable.tableName} i LEFT JOIN ${CategoriesTable.tableName} c ON i.${InventoriesTable.categoryId} = c.${CategoriesTable.id} LEFT JOIN ${UnitsTable.tableName} u ON c.${CategoriesTable.categoryUnitId} = u.${UnitsTable.id}');
    final args = <dynamic>[];
    if (warehouseId != null) {
      buffer.write(' WHERE i.${InventoriesTable.storeId} = ?');
      args.add(warehouseId);
    }

    final db = await _db.database;
    final stmt = db.prepare(buffer.toString());
    final results = stmt.select(args);
    final rows = results.map((r) => Map<String, dynamic>.from(r)).toList();
    stmt.dispose();
    return rows.map((r) {
      UnitEntity? unit;
      try {
        final unitId = r['category_unit_id'] as int?;
        if (unitId != null) {
          final unitTypeName = (r['unit_type'] as String?) ?? '';
          unit = UnitEntity(
            id: unitId,
            unitName: (r['unit_name'] as String?) ?? '',
            propertyId: null,
            length: ((r['unit_length'] ?? 0) as num).toDouble(),
            width: ((r['unit_width'] ?? 0) as num).toDouble(),
            thickness: ((r['unit_thickness'] ?? 0) as num).toDouble(),
            unitType: UnitType.of(unitTypeName),
          );
        }
      } catch (_) {
        unit = null;
      }

      return InventoryCategoryEntity(
        inventoryId: r['inventory_id'] as int,
        categoryId: r['category_id'] as int,
        warehouseId: r['store_id'] as int,
        inventoryName: (r['category_name'] as String?) ?? '',
        unitCost: ((r['unit_cost'] ?? 0) as num).toDouble(),
        countUnits: ((r['count_units'] ?? 0) as num).toDouble(),
        revenueAccountId: r['revenue_id'] as int?,
        expenseAccountId: r['expense_id'] as int?,
        incomeAccountId: r['income_stock_id'] as int?,
        outcomAccountId: r['outcome_stock_id'] as int?,
        categoryUnit: unit,
      );
    }).toList();
  }

  @override
  Future<InventoryCategoryEntity?> getInventoryCategoryByInventoryId(int id) async {
    final sql = 'SELECT i.${InventoriesTable.id} AS inventory_id, i.${InventoriesTable.categoryId} AS category_id, i.${InventoriesTable.storeId} AS store_id, i.${InventoriesTable.revenueAccountId} AS revenue_id, i.${InventoriesTable.expenseAccountId} AS expense_id, i.${InventoriesTable.incomeStockId} AS income_stock_id, i.${InventoriesTable.outcomeStockId} AS outcome_stock_id, i.${InventoriesTable.unitCost} AS unit_cost, i.${InventoriesTable.countUnits} AS count_units, c.${CategoriesTable.categoryName} AS category_name, c.${CategoriesTable.categoryUnitId} AS category_unit_id, u.${UnitsTable.unitName} AS unit_name, u.${UnitsTable.length} AS unit_length, u.${UnitsTable.width} AS unit_width, u.${UnitsTable.thickness} AS unit_thickness, u.${UnitsTable.unitType} AS unit_type FROM ${InventoriesTable.tableName} i LEFT JOIN ${CategoriesTable.tableName} c ON i.${InventoriesTable.categoryId} = c.${CategoriesTable.id} LEFT JOIN ${UnitsTable.tableName} u ON c.${CategoriesTable.categoryUnitId} = u.${UnitsTable.id} WHERE i.${InventoriesTable.id} = ? LIMIT 1';
    final db = await _db.database;
    final stmt = db.prepare(sql);
    final results = stmt.select([id]);
    final rows = results.map((r) => Map<String, dynamic>.from(r)).toList();
    stmt.dispose();
    if (rows.isEmpty) return null;
    final r = rows.first;
    UnitEntity? unit;
    try {
      final unitId = rows.first['category_unit_id'] as int?;
      if (unitId != null) {
        final unitTypeName = (rows.first['unit_type'] as String?) ?? '';
        unit = UnitEntity(
          id: unitId,
          unitName: (rows.first['unit_name'] as String?) ?? '',
          propertyId: null,
          length: ((rows.first['unit_length'] ?? 0) as num).toDouble(),
          width: ((rows.first['unit_width'] ?? 0) as num).toDouble(),
          thickness: ((rows.first['unit_thickness'] ?? 0) as num).toDouble(),
          unitType: UnitType.of(unitTypeName),
        );
      }
    } catch (_) {
      unit = null;
    }

    return InventoryCategoryEntity(
      inventoryId: r['inventory_id'] as int,
      categoryId: r['category_id'] as int,
      warehouseId: r['store_id'] as int,
      inventoryName: (r['category_name'] as String?) ?? '',
      unitCost: ((r['unit_cost'] ?? 0) as num).toDouble(),
      countUnits: ((r['count_units'] ?? 0) as num).toDouble(),
      revenueAccountId: r['revenue_id'] as int?,
      expenseAccountId: r['expense_id'] as int?,
      incomeAccountId: r['income_stock_id'] as int?,
      outcomAccountId: r['outcome_stock_id'] as int?,
      categoryUnit: unit,
    );
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
    super.revenueAccountId,
    super.expenseAccountId,
    super.incomeStockId,
    super.outcomeStockId,
    required super.inventoryName,
    required super.unitCost,
    required super.countUnits,
  });

  @override
  _InventoryLocalEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    String? inventoryName,
    double? unitCost,
    double? countUnits,
  }) {
    return _InventoryLocalEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
      inventoryName: inventoryName ?? this.inventoryName,
      unitCost: unitCost ?? this.unitCost,
      countUnits: countUnits ?? this.countUnits,
    );
  }

}
