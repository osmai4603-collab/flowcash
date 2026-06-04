import 'package:flowcash/features/inventory/data/datasources/inventory_catalog_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_catalog_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/inventory_catalogs_table.dart';

final class InventorySubcategoryLocalDataSourceImpl
    implements InventorySubcategoryDataSource {
  final SqliteService _db;
  const InventorySubcategoryLocalDataSourceImpl(this._db);

  @override
  Future<List<InventorySubcategoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(
        table: InventorySubcategoriesTable.tableName,
      );
      return rows.map(fromMap).toList();
    }
    final where =
        '${InventorySubcategoriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: InventorySubcategoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<InventorySubcategoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: InventorySubcategoriesTable.tableName,
      where: '${InventorySubcategoriesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<InventorySubcategoryEntity> insert(InventorySubcategoryEntity entity) async {
    final entityId = await _db.insert(
      table: InventorySubcategoriesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), InventorySubcategoriesTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert inventory subcategory');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<InventorySubcategoryEntity> update(InventorySubcategoryEntity entity) async {
    await _db.update(
      table: InventorySubcategoriesTable.tableName,
      data: toMap(entity),
      where: {InventorySubcategoriesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: InventorySubcategoriesTable.tableName,
      where: {InventorySubcategoriesTable.id: id},
    );
    return true;
  }

  @override
  InventorySubcategoryEntity fromMap(Map<String, dynamic> map) {
    return InventorySubcategoryEntity(
      id: map[InventorySubcategoriesTable.id] as int,
      storeId: map[InventorySubcategoriesTable.storeId] as int,
      catalogId: map[InventorySubcategoriesTable.catalogId] as int,
      revenueAccountId:
          map[InventorySubcategoriesTable.revenueAccountId] as int?,
      expenseAccountId:
          map[InventorySubcategoriesTable.expenseAccountId] as int?,
      incomeStockId: map[InventorySubcategoriesTable.incomeStockId] as int?,
      outcomeStockId: map[InventorySubcategoriesTable.outcomeStockId] as int?,
    );
  }

  @override
  Map<String, dynamic> toMap(InventorySubcategoryEntity entity) {
    return {
      if (entity.id > 0) InventorySubcategoriesTable.id: entity.id,
      InventorySubcategoriesTable.storeId: entity.storeId,
      InventorySubcategoriesTable.catalogId: entity.catalogId,
      InventorySubcategoriesTable.revenueAccountId: entity.revenueAccountId,
      InventorySubcategoriesTable.expenseAccountId: entity.expenseAccountId,
      InventorySubcategoriesTable.incomeStockId: entity.incomeStockId,
      InventorySubcategoriesTable.outcomeStockId: entity.outcomeStockId,
    };
  }

  @override
  Future<InventorySubcategoryEntity?> firstWhereStoreAndCategory({
    required int categoryId,
    required int warehouseId,
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
