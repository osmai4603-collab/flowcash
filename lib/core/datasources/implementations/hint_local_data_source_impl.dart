import 'package:flowcash/core/datasources/interfaces/hint_data_source.dart';
import 'package:flowcash/features/system/domain/entities/hint_entity.dart';
import 'package:flowcash/core/enums/hint_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/hints_table.dart';

final class HintLocalDataSourceImpl implements HintDataSource {
  final SqliteDatabase _db;
  const HintLocalDataSourceImpl(this._db);

  @override
  Future<List<HintEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: HintsTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${HintsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: HintsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<HintEntity?> getById(int id) async {
    final rows = await _db.query(
      table: HintsTable().tableName,
      where: '${HintsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<HintEntity> insert(HintEntity entity) async {
    final entityId = await _db.insert(
      table: HintsTable().tableName,
      data: _sanitizeInsertData(toMap(entity), HintsTable().id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert hint');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<HintEntity> update(HintEntity entity) async {
    await _db.update(
      table: HintsTable().tableName,
      data: toMap(entity),
      where: {HintsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: HintsTable().tableName,
      where: {HintsTable().id: id},
    );
    return true;
  }

  @override
  HintEntity fromMap(Map<String, dynamic> map) {
    return HintEntity(
      id: map[HintsTable().id] as int,
      hintName: (map[HintsTable().hintName] as String?) ?? "",
      hintType: (map[HintsTable().hintType] as String?) ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap(HintEntity entity) {
    return {
      if (entity.id > 0) HintsTable().id: entity.id,
      HintsTable().hintName: entity.hintName,
      HintsTable().hintType: entity.hintType,
    };
  }

  @override
  Future<List<HintEntity>> whereHintType(Iterable<HintType> hintTypes) async {
    if (hintTypes.isEmpty) return [];
    final where =
        '${HintsTable().hintType} IN (${List.filled(hintTypes.length, '?').join(', ')})';
    final rows = await _db.query(
      table: HintsTable().tableName,
      where: where,
      whereArgs: hintTypes.map((t) => t.name).toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<Map<int, HintEntity>> getWhereHintTypeAsMap(
    Iterable<HintType> hintTypes,
  ) async {
    final list = await whereHintType(hintTypes);
    return {for (final item in list) item.id: item};
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
