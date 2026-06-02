import 'package:flowcash/features/categories/data/datasources/category_property_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

final class CategoryPropertyLocalDataSourceImpl
    implements CategoryPropertyDataSource {
  final SqliteService _db;
  const CategoryPropertyLocalDataSourceImpl(this._db);

  @override
  Future<List<CategoryPropertyEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: CategoryPropertiesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${CategoryPropertiesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoryPropertiesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<CategoryPropertyEntity?> getById(int id) async {
    final rows = await _db.query(
      table: CategoryPropertiesTable.tableName,
      where: '${CategoryPropertiesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<CategoryPropertyEntity> insert(CategoryPropertyEntity entity) async {
    await _db.insert(
      table: CategoryPropertiesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), CategoryPropertiesTable.id),
    );
    return entity;
  }

  @override
  Future<CategoryPropertyEntity> update(CategoryPropertyEntity entity) async {
    await _db.update(
      table: CategoryPropertiesTable.tableName,
      data: toMap(entity),
      where: {CategoryPropertiesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: CategoryPropertiesTable.tableName,
      where: {CategoryPropertiesTable.id: id},
    );
    return true;
  }

  @override
  CategoryPropertyEntity fromMap(Map<String, dynamic> map) {
    return CategoryPropertyEntity(
      id: map[CategoryPropertiesTable.id] as int,
      mainCategoryId: map[CategoryPropertiesTable.mainCategoryId] as int,
      propertyName:
          (map[CategoryPropertiesTable.propertyName] as String?) ?? "",
      unitType: UnitType.values.firstWhere(
        (e) => e.name == map[CategoryPropertiesTable.unitType] as String,
      ),
      isSingle:
          (map[CategoryPropertiesTable.isSingle] == true ||
          map[CategoryPropertiesTable.isSingle] == 1),
      isCategoryUnit:
          (map[CategoryPropertiesTable.isCategoryUnit] == true ||
          map[CategoryPropertiesTable.isCategoryUnit] == 1),
      isPricingUnit:
          (map[CategoryPropertiesTable.isPricingUnit] == true ||
          map[CategoryPropertiesTable.isPricingUnit] == 1),
      isInventoryUnit:
          (map[CategoryPropertiesTable.isInventoryUnit] == true ||
          map[CategoryPropertiesTable.isInventoryUnit] == 1),
    );
  }

  @override
  Map<String, dynamic> toMap(CategoryPropertyEntity entity) {
    return {
      if (entity.id > 0) CategoryPropertiesTable.id: entity.id,
      CategoryPropertiesTable.mainCategoryId: entity.mainCategoryId,
      CategoryPropertiesTable.propertyName: entity.propertyName,
      CategoryPropertiesTable.unitType: entity.unitType.name,
      CategoryPropertiesTable.isSingle: entity.isSingle ? 1 : 0,
      CategoryPropertiesTable.isCategoryUnit: entity.isCategoryUnit ? 1 : 0,
      CategoryPropertiesTable.isPricingUnit: entity.isPricingUnit ? 1 : 0,
      CategoryPropertiesTable.isInventoryUnit: entity.isInventoryUnit ? 1 : 0,
    };
  }

  @override
  Future<List<CategoryPropertyEntity>> whereMainCategoryId(
    Iterable<int> ids, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    if (ids.isEmpty) {
      return const [];
    }

    final where =
        '${CategoryPropertiesTable.mainCategoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoryPropertiesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
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
