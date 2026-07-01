import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_category_entity.dart';
import 'package:flowcash/features/inventory/data/models/inventory_model.dart';
import 'package:flowcash/features/inventory/data/models/inventory_category_model.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

final class InventoryLocalDataSourceImpl implements InventoryDataSource {
  final SqliteDatabase _db;
  const InventoryLocalDataSourceImpl(this._db);

  @override
  Future<List<InventoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: InventoriesTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventoriesTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoriesTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventoriesTable().tableName,
      where: '${InventoriesTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventoryEntity> insert(InventoryEntity entity) async {
    final entityId = await _db.insert(
      table: InventoriesTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert inventory');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<InventoryEntity> update(InventoryEntity entity) async {
    await _db.update(
      table: InventoriesTable().tableName,
      data: toMap(entity),
      where: {InventoriesTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: InventoriesTable().tableName,
      where: {InventoriesTable().id: id},
    );
    return true;
  }

  @override
  InventoryEntity fromMap(Map<String, dynamic> map) {
    return InventoryModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(InventoryEntity entity) {
    if (entity is InventoryModel) {
      return entity.toMap();
    }
    return InventoryModel(
      id: entity.id,
      categoryId: entity.categoryId,
      storeId: entity.storeId,
      propertyAccountId: entity.propertyAccountId,
      revenueAccountId: entity.revenueAccountId,
      expenseAccountId: entity.expenseAccountId,
      incomeStockId: entity.incomeStockId,
      outcomeStockId: entity.outcomeStockId,
      inventoryName: entity.inventoryName,
      costTotal: entity.costTotal,
      countUnits: entity.countUnits,
      userId: entity.userId,
    ).toMap();
  }

  @override
  Future<List<InventoryEntity>> whereStore(
    int storeId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: InventoriesTable().tableName,
      where: '${InventoriesTable().storeId} = ?',
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
      table: InventoriesTable().tableName,
      where:
          '${InventoriesTable().categoryId} = ? AND ${InventoriesTable().storeId} = ?',
      whereArgs: [categoryId, storeId],
      limit: 1,
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
        '${InventoriesTable().storeId} = ? AND ${InventoriesTable().categoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventoriesTable().tableName,
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
    buffer.write(
      'SELECT i.${InventoriesTable().id} AS inventory_id, i.${InventoriesTable().categoryId} AS category_id, i.${InventoriesTable().storeId} AS store_id, i.${InventoriesTable().propertyAccountId} AS property_id, i.${InventoriesTable().revenueAccountId} AS revenue_id, i.${InventoriesTable().expenseAccountId} AS expense_id, i.${InventoriesTable().incomeStockId} AS income_stock_id, i.${InventoriesTable().outcomeStockId} AS outcome_stock_id, i.${InventoriesTable().costTotal} AS cost_total, i.${InventoriesTable().countUnits} AS count_units, c.${CategoriesTable().categoryName} AS category_name, c.${CategoriesTable().categoryUnitId} AS category_unit_id, u.${UnitsTable().unitName} AS unit_name, u.${UnitsTable().length} AS unit_length, u.${UnitsTable().width} AS unit_width, u.${UnitsTable().thickness} AS unit_thickness, u.${UnitsTable().unitType} AS unit_type',
    );
    buffer.write(
      ' FROM ${InventoriesTable().tableName} i LEFT JOIN ${CategoriesTable().tableName} c ON i.${InventoriesTable().categoryId} = c.${CategoriesTable().id} LEFT JOIN ${UnitsTable().tableName} u ON c.${CategoriesTable().categoryUnitId} = u.${UnitsTable().id}',
    );
    final args = <dynamic>[];
    if (warehouseId != null) {
      buffer.write(' WHERE i.${InventoriesTable().storeId} = ?');
      args.add(warehouseId);
    }

    final rows = await _db.rawQuery(
      buffer.toString(),
      warehouseId != null ? [warehouseId] : null,
    );
    return rows.map(InventoryCategoryModel.fromMap).toList();
  }

  @override
  Future<InventoryCategoryEntity?> getInventoryCategoryByInventoryId(
    int id,
  ) async {
    final sql =
        'SELECT i.${InventoriesTable().id} AS inventory_id, i.${InventoriesTable().categoryId} AS category_id, i.${InventoriesTable().storeId} AS store_id, i.${InventoriesTable().propertyAccountId} AS property_id, i.${InventoriesTable().revenueAccountId} AS revenue_id, i.${InventoriesTable().expenseAccountId} AS expense_id, i.${InventoriesTable().incomeStockId} AS income_stock_id, i.${InventoriesTable().outcomeStockId} AS outcome_stock_id, i.${InventoriesTable().costTotal} AS cost_total, i.${InventoriesTable().countUnits} AS count_units, c.${CategoriesTable().categoryName} AS category_name, c.${CategoriesTable().categoryUnitId} AS category_unit_id, u.${UnitsTable().unitName} AS unit_name, u.${UnitsTable().length} AS unit_length, u.${UnitsTable().width} AS unit_width, u.${UnitsTable().thickness} AS unit_thickness, u.${UnitsTable().unitType} AS unit_type FROM ${InventoriesTable().tableName} i LEFT JOIN ${CategoriesTable().tableName} c ON i.${InventoriesTable().categoryId} = c.${CategoriesTable().id} LEFT JOIN ${UnitsTable().tableName} u ON c.${CategoriesTable().categoryUnitId} = u.${UnitsTable().id} WHERE i.${InventoriesTable().id} = ? LIMIT 1';
    final rows = await _db.rawQuery(
      sql,
      [id]
    );
    return InventoryCategoryModel.fromMap(rows.first);
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
