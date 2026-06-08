import 'package:flowcash/core/datasources/interfaces/hint_data_source.dart';
import 'package:flowcash/features/system/domain/entities/hint_entity.dart';
import 'package:flowcash/core/enums/hint_type_enum.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/hints_table.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

final class HintLocalDataSourceImpl implements HintDataSource {
  final SqliteService _db;
  const HintLocalDataSourceImpl(this._db);

  @override
  Future<List<HintEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: HintsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${HintsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: HintsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<HintEntity?> getById(int id) async {
    final rows = await _db.query(
      table: HintsTable.tableName,
      where: '${HintsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<HintEntity> insert(HintEntity entity) async {
    final entityId = await _db.insert(
      table: HintsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), HintsTable.id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert hint');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<HintEntity> update(HintEntity entity) async {
    await _db.update(
      table: HintsTable.tableName,
      data: toMap(entity),
      where: {HintsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: HintsTable.tableName,
      where: {HintsTable.id: id},
    );
    return true;
  }

  @override
  HintEntity fromMap(Map<String, dynamic> map) {
    return HintEntity(
      id: map[HintsTable.id] as int,
      hintName: (map[HintsTable.hintName] as String?) ?? "",
      hintType: (map[HintsTable.hintType] as String?) ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap(HintEntity entity) {
    return {
      if (entity.id > 0) HintsTable.id: entity.id,
      HintsTable.hintName: entity.hintName,
      HintsTable.hintType: entity.hintType,
    };
  }

  @override
  Future<List<HintEntity>> whereHintType(Iterable<HintType> hintTypes) async {
    throw UnimplementedError();
  }

  @override
  Future<List<HintEntity>> whereBelongGroup(
    HistoriesGroup operation, {
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, HintEntity>> getWhereHintTypeAsMap(
    Iterable<HintType> hintTypes,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HintEntity?> whereHintTypeAndName(
    HistoriesGroup historyGroup,
    String hintName, {
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<HintEntity> getHintType(
    HistoriesGroup mainAccountId,
    String name,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HintEntity> getHintTypeAndName(
    HistoriesGroup mainAccountId,
    String hintName, {
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
