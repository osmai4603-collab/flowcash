import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

final class MainCategoryLocalDataSourceImpl
    implements MainCategoryLocalDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(CategoryPropertyEntity) propertyToMap;
  const MainCategoryLocalDataSourceImpl(this._db, this.propertyToMap);

  @override
  Future<List<MainCategoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: MainCategoriesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${MainCategoriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: MainCategoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<MainCategoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: MainCategoriesTable.tableName,
      where: '${MainCategoriesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<MainCategoryEntity> insert(MainCategoryEntity entity) async {
    return await _db.transaction(() async {
      final entityId = await _db.insert(
        table: MainCategoriesTable.tableName,
        data: toMap(entity),
      );
      if (entityId <= 0) {
        throw Exception('Failed to insert main category');
      }
      final insertedEntity = entity.copyWith(id: entityId);
      final properties = entity.properties
          .map(
            (property) => property.copyWith(mainCategoryId: insertedEntity.id),
          )
          .toList();
      for (var index = 0; index < properties.length; index++) {
        final property = properties[index];
        final propertyId = await _db.insert(
          table: CategoryPropertiesTable.tableName,
          data: propertyToMap(property),
        );
        if (propertyId <= 0) {
          throw Exception('Failed to insert category property at index $index');
        }
        properties[index] = property.copyWith(id: propertyId);
      }
      return insertedEntity.copyWith(properties: properties);
    });
  }

  @override
  Future<MainCategoryEntity> update(MainCategoryEntity entity) async {
    return await _db.transaction(() async {
      await _db.update(
        table: MainCategoriesTable.tableName,
        data: toMap(entity),
        where: {MainCategoriesTable.id: entity.id},
      );

      final updatedProperties = <CategoryPropertyEntity>[];
      for (var index = 0; index < entity.properties.length; index++) {
        final property = entity.properties[index].copyWith(
          mainCategoryId: entity.id,
        );

        if (property.id > 0) {
          await _db.update(
            table: CategoryPropertiesTable.tableName,
            data: propertyToMap(property),
            where: {CategoryPropertiesTable.id: property.id},
          );
          updatedProperties.add(property);
        } else {
          final propertyId = await _db.insert(
            table: CategoryPropertiesTable.tableName,
            data: propertyToMap(property),
          );
          if (propertyId <= 0) {
            throw Exception(
              'Failed to insert category property at index $index',
            );
          }
          updatedProperties.add(property.copyWith(id: propertyId));
        }
      }

      return entity.copyWith(properties: updatedProperties);
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: CategoryPropertiesTable.tableName,
        where: {CategoryPropertiesTable.mainCategoryId: id},
      );
      await _db.deleteWhere(
        table: MainCategoriesTable.tableName,
        where: {MainCategoriesTable.id: id},
      );
      return true;
    });
  }

  @override
  MainCategoryEntity fromMap(Map<String, dynamic> map) {
    return MainCategoryEntity(
      id: map[MainCategoriesTable.id] as int,
      name: (map[MainCategoriesTable.categoryName] as String?) ?? "",
      type: CategoryDefineType.values.firstWhere(
        (e) => e.name == map[MainCategoriesTable.categoryType] as String,
      ),
      unitName: (map[MainCategoriesTable.unitName] as String?) ?? "",
      unitType: UnitType.values.firstWhere(
        (e) => e.name == map[MainCategoriesTable.unitType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(MainCategoryEntity entity) {
    return {
      if (entity.id > 0) MainCategoriesTable.id: entity.id,
      MainCategoriesTable.categoryName: entity.name,
      MainCategoriesTable.categoryType: entity.type.name,
      MainCategoriesTable.unitName: entity.unitName,
      MainCategoriesTable.unitType: entity.unitType.name,
    };
  }

  @override
  Future<MainCategoryEntity?> firstWhereCategoryName(
    String categoryName,
  ) async {
    final rows = await _db.query(
      table: MainCategoriesTable.tableName,
      where: '${MainCategoriesTable.categoryName} = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }
}
