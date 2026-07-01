import 'package:flowcash/core/services/sqlite/table_by_id.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

final class SqliteDatabaseSync {
  SqliteDatabaseSync(this._db);

  final Database _db;

  T transaction<T>(T Function() action, {void Function(Object error)? onError}) {
    final inTransaction = !_db.autocommit;
    if (inTransaction) {
      return action();
    }

    _db.execute('BEGIN');
    try {
      final result = action();
      _db.execute('COMMIT');
      return result;
    } catch (e) {
      _db.execute('ROLLBACK');
      onError?.call(e);
      rethrow;
    }
  }

  void createFunction({
    required String functionName,
    required ScalarFunction function,
    AllowedArgumentCount argumentCount = const AllowedArgumentCount.any(),
    bool deterministic = false,
    bool directOnly = true,
    bool subtype = false,
  }) {
    _db.createFunction(
      functionName: functionName,
      function: function,
      argumentCount: argumentCount,
      deterministic: deterministic,
      directOnly: directOnly,
      subtype: subtype,
    );
  }

  int insert({required String table, required Map<String, Object?> data}) {
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final query = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    final stmt = _db.prepare(query);
    stmt.execute(data.values.toList());
    final lastInsertId = _db.lastInsertRowId;
    stmt.dispose();
    return lastInsertId;
  }

  void execute(String query, [List<Object?> args = const []]) {
    final stmt = _db.prepare(query);
    stmt.execute(args);
    stmt.dispose();
  }

  List<Map<String, dynamic>> query({
    required String table,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) {
    var sql = 'SELECT * FROM $table';
    if (where != null && where.isNotEmpty) {
      sql += ' WHERE $where';
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      sql += ' ORDER BY $orderBy';
    }
    if (limit != null && limit > 0) {
      sql += ' LIMIT $limit';
    }
    final stmt = _db.prepare(sql);
    final ResultSet results = stmt.select(whereArgs ?? const []);
    final list = results.map((row) => Map<String, dynamic>.from(row)).toList();
    stmt.dispose();
    return list;
  }

  Map<String, dynamic>? fetchFirst({
    required String tableName,
    String? where,
    List<Object?>? whereArgs,
  }) {
    final results = query(
      table: tableName,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Map<String, dynamic>? getById<T>({
    required TableById table,
    required T id,
  }) {
    return fetchFirst(
      tableName: table.tableName,
      where: '${table.id} = ?',
      whereArgs: [id],
    );
  }

  Model? getByIdToModel<Id, Model>({
    required TableById table,
    required Id id,
    required Model Function(Map<String, dynamic>) toModel,
  }) {
    final result = getById(table: table, id: id);
    return result != null ? toModel(result) : null;
  }

  List<Model> queryToModels<Model>({
    required String table,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    required Model Function(Map<String, dynamic>) toModel,
  }) {
    final rows = query(
      table: table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return rows.map(toModel).toList(growable: false);
  }

  Model? fetchFirstToModel<Model>({
    required String tableName,
    String? where,
    List<Object?>? whereArgs,
    required Model Function(Map<String, dynamic>) toModel,
  }) {
    final row = fetchFirst(
      tableName: tableName,
      where: where,
      whereArgs: whereArgs,
    );
    return row != null ? toModel(row) : null;
  }

  void deleteById({required TableById table, required int id}) {
    _db.execute(
      'DELETE FROM ${table.tableName} WHERE ${table.id} = ?',
      [id],
    );
  }

  void _log(String message) {
    debugPrint(message);
  }
}
