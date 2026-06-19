import 'dart:io';

import 'package:flowcash/core/services/sqlite_default_data.dart';
import 'package:flowcash/core/services/sqlite_schema_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final class SqliteDatabaseManager {
  static SqliteDatabaseManager? _instance;
  static SqliteDatabaseManager get instance =>
      _instance ??= const SqliteDatabaseManager._();
  const SqliteDatabaseManager._();

  static Database? _database;
  static String? _databasePath;
  static const int _version = SqliteSchemaManager.currentVersion;
  static const String _dbName = 'cashing.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = join(dbFolder.path, _dbName);
    _databasePath = path;

    debugPrint('DATABASE PATH: $path');

    final db = sqlite3.open(path);

    // Enable foreign keys
    db.execute('PRAGMA foreign_keys = ON');

    final currentVersion = db.userVersion;

    if (currentVersion == 0) {
      // Fresh DB: create the full schema and insert defaults.
      SqliteSchemaManager.createAll(db);
      DefaultDataInserter.insertDefaults(db);
      db.userVersion = _version;
    } else if (currentVersion < _version) {
      // Incremental migrations from the existing schema to the current version.
      SqliteSchemaManager.migrate(db, currentVersion, _version);
      db.userVersion = _version;
      DefaultDataInserter.insertDefaults(db);
    } else {
      // Existing DB at current schema version: ensure required default rows exist.
      DefaultDataInserter.insertDefaults(db);
    }

    return db;
  }

  // Schema and default data are handled by SqliteSchemaManager and DefaultDataInserter.
}

final class SqliteService {
  static SqliteService? _instance;
  static SqliteService get instance => _instance ??= const SqliteService._();
  const SqliteService._();
  factory SqliteService() => instance;

  Future<Database> get database async =>
      SqliteDatabaseManager.instance.database;

  /// Insert a map of values into the database and return the last inserted row id.
  Future<int> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    _validateNotNullBillNumber(table: table, data: data);

    final db = await database;
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final query = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    debugPrint(
      'INSERT INTO $table ($columns) VALUES ("${data.values.join('", "')}")',
    );
    final stmt = db.prepare(query);
    stmt.execute(data.values.toList());
    final lastInsertId = db.lastInsertRowId;
    stmt.dispose();
    return lastInsertId;
  }

  /// Insert a list of maps of values into the database.
  Future<void> insertAll({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    if (dataList.isEmpty) return;
    final db = await database;
    final columns = dataList.first.keys.join(', ');
    final placeholders = List.filled(dataList.first.length, '?').join(', ');
    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    debugPrint(sql);
    final stmt = db.prepare(sql);

    for (final data in dataList) {
      _validateNotNullBillNumber(table: table, data: data);
      stmt.execute(data.values.toList());
    }
    stmt.dispose();
  }

  Future<T> transaction<T>(Future<T> Function() action) async {
    final db = await database;
    debugPrint(
      'Start Transaction....................................................',
    );
    db.execute('BEGIN');
    try {
      final result = await action();
      debugPrint(
        'Commit Transaction....................................................',
      );
      db.execute('COMMIT');
      return result;
    } catch (e) {
      debugPrint(e.toString());
      debugPrint(
        'RollBack Transaction....................................................',
      );
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// Update rows in the database matching [where] conditions.
  Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> where,
  }) async {
    _validateNotNullBillNumber(table: table, data: data);

    final db = await database;
    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final sql = 'UPDATE $table SET $setClause WHERE $whereClause';
    final stmt = db.prepare(sql);
    debugPrint('${sql}with args: ${data.values.join()}');
    stmt.execute([...data.values, ...where.values]);
    stmt.dispose();
  }

  void _validateNotNullBillNumber({
    required String table,
    required Map<String, dynamic> data,
  }) {
    if (data.containsKey('bill_number') && data['bill_number'] == null) {
      throw ArgumentError.value(
        data['bill_number'],
        'bill_number',
        'bill_number must not be null for table $table',
      );
    }
  }

  /// Delete rows matching [where] conditions.
  Future<void> deleteWhere({
    required String table,
    required Map<String, dynamic> where,
  }) async {
    final db = await database;
    if (where.isEmpty) {
      db.execute('DELETE FROM $table');
      return;
    }
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final stmt = db.prepare('DELETE FROM $table WHERE $whereClause');
    stmt.execute(where.values.toList());
    stmt.dispose();
  }

  /// Query the database and return a list of rows.
  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
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
    debugPrint('$sql with args: $whereArgs');
    final stmt = db.prepare(sql);
    final ResultSet results = stmt.select(whereArgs ?? const []);

    final List<Map<String, dynamic>> list = [];
    for (final row in results) {
      debugPrint(
        '  ${row.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}',
      );
      list.add(Map<String, dynamic>.from(row));
    }
    list.isEmpty ? debugPrint('  NO ROWS RETURNED.\n') : debugPrint('');
    stmt.dispose();
    return list;
  }

  /// Executes a raw SQL query and returns the results as a list of maps.
  Future<List<Map<String, dynamic>>> rawQuery(
    String query, [
    List<Object?>? args,
  ]) async {
    final db = await database;
    debugPrint('$query with args: $args');
    final stmt = db.prepare(query);
    final ResultSet results = stmt.select(args ?? const []);
    final List<Map<String, dynamic>> list =
        results.map((row) => Map<String, dynamic>.from(row)).toList();
    stmt.dispose();
    return list;
  }

  Future<String> get databasePath async {
    if (SqliteDatabaseManager._databasePath != null) {
      return SqliteDatabaseManager._databasePath!;
    }
    await database;
    return SqliteDatabaseManager._databasePath!;
  }

  Future<File> copyDatabase(String destinationPath) async {
    final sourcePath = await databasePath;
    final file = File(sourcePath);
    return await file.copy(destinationPath);
  }

  Future<void> execute(String query) async {
    final db = await database;
    db.execute(query);
  }

  Future<List<String>> getTableNames() async {
    final db = await database;
    final stmt = db.prepare(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    final ResultSet result = stmt.select();
    final names = <String>[];
    for (final row in result) {
      names.add(row['name'] as String);
    }
    stmt.dispose();
    return names;
  }
}
