import 'package:flowcash/features/categories/data/datasources/category_attribute_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';

final class CategoryAttributeLocalDataSourceImpl
    implements CategoryAttributeDataSource {
  final SqliteService _db;
  const CategoryAttributeLocalDataSourceImpl(this._db);

  @override
  Future<List<CategoryAttributeEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: CategoriesAttributesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${CategoriesAttributesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoriesAttributesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<CategoryAttributeEntity?> getById(int id) async {
    final rows = await _db.query(
      table: CategoriesAttributesTable.tableName,
      where: '${CategoriesAttributesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<CategoryAttributeEntity> insert(CategoryAttributeEntity entity) async {
    final entityId = await _db.insert(
      table: CategoriesAttributesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), CategoriesAttributesTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert category attribute');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<CategoryAttributeEntity> update(CategoryAttributeEntity entity) async {
    await _db.update(
      table: CategoriesAttributesTable.tableName,
      data: toMap(entity),
      where: {CategoriesAttributesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: CategoriesAttributesTable.tableName,
      where: {CategoriesAttributesTable.id: id},
    );
    return true;
  }

  @override
  CategoryAttributeEntity fromMap(Map<String, dynamic> map) {
    return CategoryAttributeEntity(
      id: map[CategoriesAttributesTable.id] as int,
      subcategoryUnitId:
          map[CategoriesAttributesTable.subcategoryUnitId] as int,
      categoryId: map[CategoriesAttributesTable.categoryId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(CategoryAttributeEntity entity) {
    return {
      if (entity.id > 0) CategoriesAttributesTable.id: entity.id,
      CategoriesAttributesTable.subcategoryUnitId: entity.subcategoryUnitId,
      CategoriesAttributesTable.categoryId: entity.categoryId,
    };
  }

  @override
  Future<List<CategoryAttributeEntity>> whereCategoryId(
    Iterable<int> ids, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    if (ids.isEmpty) return <CategoryAttributeEntity>[];
    final where =
        '${CategoriesAttributesTable.categoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoriesAttributesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<CategoryAttributeEntity>> whereSubcategoryUnitId(
    Iterable<int> ids, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    if (ids.isEmpty) return <CategoryAttributeEntity>[];
    final where =
        '${CategoriesAttributesTable.subcategoryUnitId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoriesAttributesTable.tableName,
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
