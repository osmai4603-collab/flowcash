import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';

final class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(CategoryAttributeEntity) attributeToMap;
  const CategoryLocalDataSourceImpl(this._db, this.attributeToMap);

  @override
  Future<List<CategoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: CategoriesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${CategoriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<CategoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      where: '${CategoriesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<CategoryEntity> insert(CategoryEntity entity) async {
    return await _db.transaction(() async {
      final categoryId = await _db.insert(
        table: CategoriesTable.tableName,
        data: _sanitizeInsertData(
          toMap(entity, includeId: entity.id > 0),
          CategoriesTable.id,
        ),
      );

      for (var index = 0; index < entity.attributes.length; index++) {
        entity.attributes[index] = entity.attributes[index].copyWith(categoryId: categoryId);
        final attribute =
            entity.attributes[index].copyWith(categoryId: categoryId);
        final attributeId = await _db.insert(
          table: CategoriesAttributesTable.tableName,
          data: _sanitizeInsertData(
            attributeToMap(attribute),
            CategoriesAttributesTable.id,
          ),
        );
        if (attributeId <= 0) {
          throw Exception(
            'Failed to insert category attribute at index $index',
          );
        }
        entity.attributes[index] = attribute.copyWith(id: attributeId);
      }

      return entity.copyWith(id: categoryId);
    });
  }

  @override
  Future<CategoryEntity> update(CategoryEntity entity) async {
    return await _db.transaction(() async {
      await _db.update(
        table: CategoriesTable.tableName,
        data: toMap(entity),
        where: {CategoriesTable.id: entity.id},
      );

      final updatedAttributes = <CategoryAttributeEntity>[];
      for (var index = 0; index < entity.attributes.length; index++) {
        final attribute = entity.attributes[index].copyWith(
          categoryId: entity.id,
        );

        if (attribute.id > 0) {
          await _db.update(
            table: CategoriesAttributesTable.tableName,
            data: attributeToMap(attribute),
            where: {CategoriesAttributesTable.id: attribute.id},
          );
          updatedAttributes.add(attribute);
        } else {
          final attributeId = await _db.insert(
            table: CategoriesAttributesTable.tableName,
            data: _sanitizeInsertData(
              attributeToMap(attribute),
              CategoriesAttributesTable.id,
            ),
          );
          if (attributeId <= 0) {
            throw Exception('Failed to insert category attribute at index $index');
          }
          updatedAttributes.add(attribute.copyWith(id: attributeId));
        }
      }

      return entity.copyWith(attributes: updatedAttributes);
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: CategoriesAttributesTable.tableName,
        where: {CategoriesAttributesTable.categoryId: id},
      );
      await _db.deleteWhere(
        table: CategoriesTable.tableName,
        where: {CategoriesTable.id: id},
      );
      return true;
    });
  }

  @override
  CategoryEntity fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map[CategoriesTable.id] as int,
      categoryType: CategoryDefineType.values.firstWhere(
        (e) => e.name == map[CategoriesTable.categoryType] as String,
      ),
      categoryName: (map[CategoriesTable.categoryName] as String?) ?? "",
      categoryNumber: (map[CategoriesTable.categoryNumber] as String?) ?? "",
      barcode: map[CategoriesTable.barcode] as String?,
      categoryUnitId: map[CategoriesTable.categoryUnitId] as int,
      pricingUnitId: map[CategoriesTable.pricingUnitId] as int,
      inventoryUnitId: map[CategoriesTable.inventoryUnitId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(CategoryEntity entity, {bool includeId = true}) {
    final data = {
      CategoriesTable.categoryType: entity.categoryType.name,
      CategoriesTable.categoryName: entity.categoryName,
      CategoriesTable.categoryNumber: entity.categoryNumber,
      CategoriesTable.barcode: entity.barcode,
      CategoriesTable.categoryUnitId: entity.categoryUnitId,
      CategoriesTable.pricingUnitId: entity.pricingUnitId,
      CategoriesTable.inventoryUnitId: entity.inventoryUnitId,
    };

    if (includeId && entity.id > 0) {
      data[CategoriesTable.id] = entity.id;
    }

    return data;
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

  @override
  Future<CategoryEntity?> firstWhereCategoryName(
    String categoryName, {
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      where: '${CategoriesTable.categoryName} = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final category = fromMap(rows.first);
    // load attributes
    final attrs = await _db.query(
      table: CategoriesAttributesTable.tableName,
      where: '${CategoriesAttributesTable.categoryId} = ?',
      whereArgs: [category.id],
    );
    final attributes = attrs
        .map((row) => CategoryAttributeEntity(
              id: row[CategoriesAttributesTable.id] as int,
              subcategoryUnitId:
                  row[CategoriesAttributesTable.subcategoryUnitId] as int,
              categoryId: row[CategoriesAttributesTable.categoryId] as int,
            ))
        .toList();
    return category.copyWith(attributes: attributes);
  }

  @override
  Future<bool> hasCategoryName(
    String categoryName, {
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      where: '${CategoriesTable.categoryName} = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<CategoryEntity>> whereNotInStore(
    int storeId, {
    bool printQuery = true,
  }) async {
    // Not enough context about store stock table; return empty list to be safe.
    return <CategoryEntity>[];
  }

  @override
  Future<List<SimpleCategoryEntity>> whereCategoryNameContains(
    String categoryName, {
    int? limit,
  }) async {
    final like = '%$categoryName%';
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      where: '${CategoriesTable.categoryName} LIKE ?',
      whereArgs: [like],
      limit: limit,
    );
    final results = <SimpleCategoryEntity>[];
    for (final row in rows) {
      final unitId = row[CategoriesTable.categoryUnitId] as int;
      final unitRows = await _db.query(
        table: UnitsTable.tableName,
        where: '${UnitsTable.id} = ?',
        whereArgs: [unitId],
        limit: 1,
      );
      String unitName = '';
      UnitType unitType = UnitType.piece;
      if (unitRows.isNotEmpty) {
        unitName = (unitRows.first[UnitsTable.unitName] as String?) ?? '';
        unitType = UnitType.values.firstWhere(
          (e) => e.name == unitRows.first[UnitsTable.unitType] as String,
        );
      }
      results.add(SimpleCategoryEntity(
        id: row[CategoriesTable.id] as int,
        categoryName: (row[CategoriesTable.categoryName] as String?) ?? '',
        unitName: unitName,
        unitType: unitType,
      ));
    }
    return results;
  }

  @override
  Future<String> getNewCategoryNumber() async {
    final rows = await _db.query(
      table: CategoriesTable.tableName,
      orderBy: '${CategoriesTable.id} DESC',
      limit: 1,
    );
    if (rows.isEmpty) return "1";
    final lastId = rows.first[CategoriesTable.id] as int;
    return (lastId + 1).toString();
  }
}
