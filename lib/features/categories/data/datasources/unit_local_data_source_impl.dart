import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

final class UnitLocalDataSourceImpl implements UnitLocalDataSource {
  final SqliteDatabase _db;
  const UnitLocalDataSourceImpl(this._db);

  @override
  Future<List<UnitEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: UnitsTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${UnitsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: UnitsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<UnitEntity?> getById(int id) async {
    final rows = await _db.query(
      table: UnitsTable().tableName,
      where: '${UnitsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<UnitEntity> insert(UnitEntity entity) async {
    final entityId = await _db.insert(
      table: UnitsTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert unit');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<UnitEntity> update(UnitEntity entity) async {
    await _db.update(
      table: UnitsTable().tableName,
      data: toMap(entity),
      where: {UnitsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: UnitsTable().tableName,
      where: {UnitsTable().id: id},
    );
    return true;
  }

  @override
  UnitEntity fromMap(Map<String, dynamic> map) {
    return UnitModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(UnitEntity entity) {
    if (entity is UnitModel) {
      return entity.toMap();
    }
    return UnitModel(
      id: entity.id,
      unitName: entity.unitName,
      propertyId: entity.propertyId,
      measurement: entity.measurement,
      unitType: entity.unitType,
    ).toMap();
  }

  @override
  Future<List<UnitEntity>> whereBasic({bool printQuery = true}) async {
    final types = UnitType.values
        .where((type) => type.isBasic)
        .map((e) => e.name)
        .toList();
    final result = await _db.query(
      table: UnitsTable().tableName,
      where:
          '${UnitsTable().unitType} IN (${List.filled(types.length, '?').join(', ')}) AND ${UnitsTable().length} == ? AND ${UnitsTable().width} == ? AND ${UnitsTable().thickness} == ?',
      whereArgs: [...types, 0.0, 0.0, 0.0],
    );
    return result.map(fromMap).toList();
  }

  @override
  Future<UnitEntity?> getFirstWhereArgs({
    double? length,
    double? width,
    double? thickness,
    required int propertyId,
    required UnitType unitType,
    String? unitName,
  }) async {
    final List<String> where = ['${UnitsTable().unitType} = ?'];
    final List<dynamic> args = [unitType.name];

    if (length != null) {
      where.add('${UnitsTable().length} = ?');
      args.add(length);
    }
    if (width != null) {
      where.add('${UnitsTable().width} = ?');
      args.add(width);
    }
    if (thickness != null) {
      where.add('${UnitsTable().thickness} = ?');
      args.add(thickness);
    }
    if (unitName != null && unitName.isNotEmpty) {
      where.add('${UnitsTable().unitName} = ?');
      args.add(unitName);
    }

    final rows = await _db.query(
      table: UnitsTable().tableName,
      where: where.join(' AND '),
      whereArgs: args,
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<List<UnitEntity>> getByMainCategory(int mainCategoryId) async {
    final String query =
        '''
      SELECT * FROM ${UnitsTable().tableName}
      WHERE ${UnitsTable().id} IN (
        SELECT ${SubcategoriesUnitsTable().unitId}
        FROM ${SubcategoriesUnitsTable().tableName}
        WHERE ${SubcategoriesUnitsTable().subcategoryId} IN (
          SELECT ${SubcategoriesTable().id}
          FROM ${SubcategoriesTable().tableName}
          WHERE ${SubcategoriesTable().mainCategoryId} = ?
        )
      )
    ''';

    final rows = await _db.rawQuery(query, [mainCategoryId]);
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<UnitEntity>> getAvailableForSubcategoryProperty({
    required int subcategoryId,
    required int propertyId,
  }) async {
    final query = '''
      SELECT * FROM ${UnitsTable().tableName}
      WHERE ${UnitsTable().unitType} = (
        SELECT ${CategoryPropertiesTable().unitType} 
        FROM ${CategoryPropertiesTable().tableName} 
        WHERE ${CategoryPropertiesTable().id} = ? 
        LIMIT 1
      )
      AND ${UnitsTable().id} NOT IN (
        SELECT ${SubcategoriesUnitsTable().unitId} 
        FROM ${SubcategoriesUnitsTable().tableName} 
        WHERE ${SubcategoriesUnitsTable().subcategoryId} = ? 
        AND ${SubcategoriesUnitsTable().propertyId} = ?
      )
    ''';

    final rows = await _db.rawQuery(query, [propertyId, subcategoryId, propertyId]);
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<UnitEntity>> getUnitsBySubcategoryAndPropertyIds({
    required int subcategoryId,
    required List<int> propertyIds,
  }) async {
    if (propertyIds.isEmpty) return [];

    final placeholders = List.filled(propertyIds.length, '?').join(', ');
    final query = '''
      SELECT * FROM ${UnitsTable().tableName}
      WHERE ${UnitsTable().id} IN (
        SELECT ${SubcategoriesUnitsTable().unitId}
        FROM ${SubcategoriesUnitsTable().tableName}
        WHERE ${SubcategoriesUnitsTable().subcategoryId} = ?
        AND ${SubcategoriesUnitsTable().propertyId} IN ($placeholders)
      )
    ''';

    final rows = await _db.rawQuery(query, [subcategoryId, ...propertyIds]);
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<UnitEntity>> getUnitsBySubcategoryIds(
    List<int> subcategoryIds,
  ) async {
    if (subcategoryIds.isEmpty) return [];
    final ids = subcategoryIds.toSet();

    final placeholders = List.filled(ids.length, '?').join(', ');

    final unitsTable = UnitsTable();
    final subcategoriesUnitsTable = SubcategoriesUnitsTable();

    final rows = await _db.query(table: UnitsTable().tableName,
      where: '${unitsTable.id} IN (SELECT ${subcategoriesUnitsTable.unitId} FROM ${subcategoriesUnitsTable.tableName} WHERE ${subcategoriesUnitsTable.subcategoryId} IN ($placeholders))',
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }
}
