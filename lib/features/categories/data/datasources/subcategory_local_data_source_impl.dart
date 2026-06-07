import 'package:flowcash/features/categories/data/datasources/subcategory_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';

final class SubcategoryLocalDataSourceImpl
    implements SubcategoryLocalDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(SubcategoryUnitEntity) unitToMap;
  const SubcategoryLocalDataSourceImpl(this._db, this.unitToMap);

  @override
  Future<List<SubcategoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: SubcategoriesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${SubcategoriesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<SubcategoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: SubcategoriesTable.tableName,
      where: '${SubcategoriesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<SubcategoryEntity> insert(SubcategoryEntity entity) async {
    return await insertWithUnits(entity);
  }

  @override
  Future<SubcategoryEntity> update(SubcategoryEntity entity) async {
    return await saveWithUnits(entity, entity.units);
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: SubcategoriesUnitsTable.tableName,
        where: {SubcategoriesUnitsTable.subcategoryId: id},
      );
      await _db.deleteWhere(
        table: SubcategoriesTable.tableName,
        where: {SubcategoriesTable.id: id},
      );
      return true;
    });
  }

  @override
  SubcategoryEntity fromMap(Map<String, dynamic> map) {
    return SubcategoryEntity(
      id: map[SubcategoriesTable.id],
      mainCategoryId: map[SubcategoriesTable.mainCategoryId] as int,
      catalogName: (map[SubcategoriesTable.catalogName] as String?) ?? "",
      catalogNumber: map[SubcategoriesTable.catalogNumber] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(SubcategoryEntity entity) {
    return {
      if (entity.id > 0) SubcategoriesTable.id: entity.id,
      SubcategoriesTable.mainCategoryId: entity.mainCategoryId,
      SubcategoriesTable.catalogName: entity.catalogName,
      SubcategoriesTable.catalogNumber: entity.catalogNumber,
    };
  }

  @override
  Future<List<SubcategoryEntity>> whereMainCategoryId(Iterable<int> ids) async {
    if (ids.isEmpty) return const [];

    final where =
        '${SubcategoriesTable.mainCategoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubcategoryUnitEntity>> getUnitsBySubcategoryIds(
      Iterable<int> ids) async {
    if (ids.isEmpty) return const [];

    final where =
        '${SubcategoriesUnitsTable.subcategoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesUnitsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );

    return rows.map((row) {
      return SubcategoryUnitEntity(
        id: row[SubcategoriesUnitsTable.id] as int,
        subcategoryId: row[SubcategoriesUnitsTable.subcategoryId] as int,
        unitId: row[SubcategoriesUnitsTable.unitId] as int,
        propertyId: row[SubcategoriesUnitsTable.propertyId] as int,
      );
    }).toList();
  }

  @override
  Future<SubcategoryEntity> insertWithUnits(SubcategoryEntity entity) async {
    return await _db.transaction(() async {
      // Insert subcategory
      final subcategoryId = await _db.insert(
        table: SubcategoriesTable.tableName,
        data: _sanitizeInsertData(toMap(entity), SubcategoriesTable.id),
      );

      final savedUnits = <SubcategoryUnitEntity>[];
      for (final unit in entity.units) {
        final toInsert = unit.copyWith(subcategoryId: subcategoryId);
        final id = await _db.insert(
          table: SubcategoriesUnitsTable.tableName,
          data: _sanitizeInsertData(unitToMap(toInsert), SubcategoriesUnitsTable.id),
        );
        savedUnits.add(toInsert.copyWith(id: id));
      }

      return entity.copyWith(id: subcategoryId, units: savedUnits);
    });
  }

  @override
  Future<SubcategoryUnitEntity> insertSubcategoryUnit(SubcategoryUnitEntity entity) async {
    final id = await _db.insert(
      table: SubcategoriesUnitsTable.tableName,
      data: _sanitizeInsertData(unitToMap(entity), SubcategoriesUnitsTable.id),
    );
    return entity.copyWith(id: id);
  }

  @override
  Future<SubcategoryUnitEntity> updateSubcategoryUnit(
      SubcategoryUnitEntity entity) async {
    await _db.update(
      table: SubcategoriesUnitsTable.tableName,
      data: unitToMap(entity),
      where: {SubcategoriesUnitsTable.id: entity.id},
    );
    return entity;
  }


  @override
  Future<SubcategoryEntity> saveWithUnits(
    SubcategoryEntity entity,
    List<SubcategoryUnitEntity> units,
  ) async {
    return await _db.transaction(() async {
      var persistedEntity = entity;

      if (entity.id > 0) {
        await update(entity);

        final existingRows = await _db.query(
          table: SubcategoriesUnitsTable.tableName,
          where: '${SubcategoriesUnitsTable.subcategoryId} = ?',
          whereArgs: [entity.id],
        );
        final existingIds = existingRows
            .map((row) => row[SubcategoriesUnitsTable.id] as int)
            .toSet();
        final selectedIds = units
            .where((unit) => unit.id > 0)
            .map((unit) => unit.id)
            .toSet();
        final deleteIds = existingIds.difference(selectedIds);

        for (final deleteId in deleteIds) {
          await _db.deleteWhere(
            table: SubcategoriesUnitsTable.tableName,
            where: {SubcategoriesUnitsTable.id: deleteId},
          );
        }
      } else {
        final id = await _db.insert(
          table: SubcategoriesTable.tableName,
          data: _sanitizeInsertData(
            toMap(entity),
            SubcategoriesTable.id,
          ),
        );
        persistedEntity = entity.copyWith(id: id);
      }

      final savedUnits = <SubcategoryUnitEntity>[];
      for (final unit in units) {
        final updatedUnit = unit.copyWith(subcategoryId: persistedEntity.id);
        if (updatedUnit.id > 0) {
          await updateSubcategoryUnit(updatedUnit);
          savedUnits.add(updatedUnit);
        } else {
          final id = await _db.insert(
            table: SubcategoriesUnitsTable.tableName,
            data: _sanitizeInsertData(
              unitToMap(updatedUnit),
              SubcategoriesUnitsTable.id,
            ),
          );
          savedUnits.add(updatedUnit.copyWith(id: id));
        }
      }

      return persistedEntity.copyWith(units: savedUnits);
    });
  }

  @override
  Future<SubcategoryEntity?> firstWhereCategory(int categoryId) async {
    final rows = await _db.query(
      table: SubcategoriesTable.tableName,
      where: '${SubcategoriesTable.id} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
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
