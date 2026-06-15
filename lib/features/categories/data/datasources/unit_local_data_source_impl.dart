import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

final class UnitLocalDataSourceImpl implements UnitLocalDataSource {
  final SqliteService _db;
  const UnitLocalDataSourceImpl(this._db);

  @override
  Future<List<UnitEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: UnitsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${UnitsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: UnitsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<UnitEntity?> getById(int id) async {
    final rows = await _db.query(
      table: UnitsTable.tableName,
      where: '${UnitsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<UnitEntity> insert(UnitEntity entity) async {
    final entityId = await _db.insert(
      table: UnitsTable.tableName,
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
      table: UnitsTable.tableName,
      data: toMap(entity),
      where: {UnitsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: UnitsTable.tableName,
      where: {UnitsTable.id: id},
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
      length: entity.length,
      width: entity.width,
      thickness: entity.thickness,
      unitType: entity.unitType,
    ).toMap();
  }

  @override
  Future<List<UnitEntity>> wherePropertyId(
    Iterable<int> ids, {
    bool trigger = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<UnitEntity>> whereBasic({bool printQuery = true}) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}
