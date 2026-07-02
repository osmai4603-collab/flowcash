import 'package:flowcash/core/services/sqlite/table_by_id.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

final class SqliteDatabase {
  SqliteDatabase(this._db);

  final Database _db;

  /// Insert a map of values into the database and return the last inserted row id.
  Future<int> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final query = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    _log(
      'INSERT INTO $table ($columns) VALUES ("${data.values.join('", "')}")',
    );
    final stmt = _db.prepare(query);
    stmt.execute(data.values.toList());
    final lastInsertId = _db.lastInsertRowId;
    stmt.dispose();
    return lastInsertId;
  }

  /// Insert a list of maps of values into the database.
  Future<void> insertAll({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    if (dataList.isEmpty) return;

    final columns = dataList.first.keys.join(', ');
    final placeholders = List.filled(dataList.first.length, '?').join(', ');
    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    _log(sql);
    final stmt = _db.prepare(sql);

    for (final data in dataList) {
      stmt.execute(data.values.toList());
    }
    stmt.dispose();
  }

  Future<T> transaction<T>(Future<T> Function() action) async {
    final inTransaction = !_db.autocommit;
    if (inTransaction) {
      _log('Nested transaction detected, running action directly...');
      return await action();
    }
    _log(
      'Start Transaction....................................................',
    );
    _db.execute('BEGIN');
    try {
      final result = await action();
      _log(
        'Commit Transaction....................................................',
      );
      _db.execute('COMMIT');
      return result;
    } catch (e) {
      _log(e.toString());
      _log(
        'RollBack Transaction....................................................',
      );
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// Update rows in the database matching [where] conditions.
  Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> where,
  }) async {
    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final sql = 'UPDATE $table SET $setClause WHERE $whereClause';
    final stmt = _db.prepare(sql);
    _log('$sql,  with args: ${[...data.values, ...where.values].join(', ')}');
    stmt.execute([...data.values, ...where.values]);
    stmt.dispose();
  }

  Future<Map<String, dynamic>?> getById<T>({
    required TableById table,
    required T id,
  }) async {
    return fetchFirst(
      tableName: table.tableName,
      where: '${table.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Model?> getByIdToModel<Id, Model>({
    required TableById table,
    required Id id,
    required Model Function(Map<String, dynamic>) toModel,
  }) async {
    final result = await getById(table: table, id: id);
    return result != null ? toModel(result) : null;
  }

  Future<bool> deleteById<T>({required TableById table, required T id}) async {
    await deleteWhere(table: table.tableName, where: {table.id: id});
    return true;
  }

  Future<List<Map<String, dynamic>>> getByIds<T>({
    required TableById table,
    required Iterable<T> ids,
  }) async {
    if (ids.isEmpty) return [];
    final rowsIds = ids.toSet().toList();

    final placeholders = List.filled(rowsIds.length, '?').join(', ');
    return query(
      table: table.tableName,
      where: '${table.id} IN ($placeholders)',
      whereArgs: rowsIds,
      limit: rowsIds.length,
    );
  }

  Future<List<Model>> getByIdsToModel<T, Model>({
    required TableById table,
    required Iterable<T> ids,
    required Model Function(Map<String, dynamic>) toModel,
  }) async {
    if (ids.isEmpty) return [];
    final rowsIds = ids.toSet().toList();

    final placeholders = List.filled(rowsIds.length, '?').join(', ');
    return queryToModels(
      table: table.tableName,
      where: '${table.id} IN ($placeholders)',
      whereArgs: rowsIds,
      limit: rowsIds.length,
      toModel: toModel,
    );
  }

  Future<bool> deleteByIds<T>({
    required TableById table,
    required Iterable<T> ids,
  }) async {
    if (ids.isEmpty) return true;

    final rowsIds = ids.toSet().toList();
    _db.execute(
      'DELETE FROM ${table.tableName} WHERE ${table.id} IN (${List.filled(rowsIds.length, '?').join(', ')})',
      rowsIds,
    );
    return true;
  }

  /// Delete rows matching [where] conditions.
  Future<void> deleteWhere({
    required String table,
    required Map<String, dynamic> where,
  }) async {
    if (where.isEmpty) {
      _db.execute('DELETE FROM $table');
      return;
    }
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final stmt = _db.prepare('DELETE FROM $table WHERE $whereClause');
    stmt.execute(where.values.toList());
    stmt.dispose();
  }

  Future<Map<String, dynamic>?> fetchFirst({
    required String tableName,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final result = await query(
      table: tableName,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.firstOrNull;
  }

  Future<Model?> fetchFirstModel<Model>({
    required String tableName,
    String? where,
    List<Object?>? whereArgs,
    required Model Function(Map<String, dynamic>) toModel,
  }) async {
    final result = await fetchFirst(
      tableName: tableName,
      where: where,
      whereArgs: whereArgs,
    );
    return result != null ? toModel(result) : null;
  }

  /// Query the database and return a list of rows.
  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
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
    _log('$sql with args: $whereArgs');
    final stmt = _db.prepare(sql);
    final ResultSet results = stmt.select(whereArgs ?? const []);

    final List<Map<String, dynamic>> list = [];
    for (final row in results) {
      _log(
        '  ${row.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}',
      );
      list.add(Map<String, dynamic>.from(row));
    }
    list.isEmpty ? _log('  NO ROWS RETURNED.\n') : _log('');
    stmt.dispose();
    return list;
  }

  /// Executes a raw SQL query and returns the results as a list of maps.
  Future<List<Map<String, dynamic>>> rawQuery(
    String query, [
    List<Object?>? args,
  ]) async {
    _log('$query with args: $args');
    final stmt = _db.prepare(query);
    final ResultSet results = stmt.select(args ?? const []);
    final List<Map<String, dynamic>> list = results
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    stmt.dispose();
    return list;
  }

  /// Registers a SQLite scalar function for use in SQL queries and triggers.
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

  Future<void> execute(String query) async {
    _db.execute(query);
  }

  void _log(String message) {
    debugPrint(message);
  }
  
  Future<List<Model>> queryToModels<Model>({required String table, required String where, required List<Object?> whereArgs, required int limit, required Model Function(Map<String, dynamic>) toModel}) async {
    final rows = await query(
      table: table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
    return rows.map(toModel).toList(growable: false);
  }

}
