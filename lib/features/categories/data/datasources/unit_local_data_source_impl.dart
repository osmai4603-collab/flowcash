import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
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
    if(entityId < 0) {
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
    return UnitEntity(
      id: map[UnitsTable.id] as int,
      unitName: (map[UnitsTable.unitName] as String?) ?? "",
      length: ((map[UnitsTable.length]) as num).toDouble(),
      width: ((map[UnitsTable.width]) as num).toDouble(),
      thickness: ((map[UnitsTable.thickness]) as num).toDouble(),
      unitType: UnitType.values.firstWhere(
        (e) => e.name == map[UnitsTable.unitType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(UnitEntity entity) {
    return {
      if (entity.id > 0) UnitsTable.id: entity.id,
      UnitsTable.unitName: entity.unitName,
      UnitsTable.length: entity.length,
      UnitsTable.width: entity.width,
      UnitsTable.thickness: entity.thickness,
      UnitsTable.unitType: entity.unitType.name,
    };
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
