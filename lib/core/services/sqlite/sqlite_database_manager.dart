import 'dart:io';

import 'package:flowcash/core/services/sqlite/sqlite_default_data.dart';
import 'package:flowcash/core/services/sqlite/sqlite_functions/bill_post_to_accounting_function.dart';
import 'package:flowcash/core/services/sqlite/sqlite_schema_manager.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

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
    final dbFolder = await getApplicationSupportDirectory();
    final path = join(dbFolder.path, _dbName);
    _databasePath = path;

    debugPrint('DATABASE PATH: $path');

    final db = sqlite3.open(path);

    db.execute('PRAGMA foreign_keys = ON');

    BillPostToAccountingFunction(SqliteDatabaseSync(db)).call();

    final currentVersion = db.userVersion;

    if (currentVersion == 0) {
      SqliteSchemaManager.createAll(db);
      DefaultDataInserter.insertDefaults(db);
      db.userVersion = _version;
    } else if (currentVersion < _version) {
      SqliteSchemaManager.migrate(db, currentVersion, _version);
      db.userVersion = _version;
      DefaultDataInserter.insertDefaults(db);
    } else {
      DefaultDataInserter.insertDefaults(db);
    }

    return db;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      _database!.dispose();
      _database = null;
    }
  }

  Future<String> get databasePath async {
    if (_databasePath != null) {
      return _databasePath!;
    }
    await database;
    return _databasePath!;
  }

  Future<File> copyDatabase(String destinationPath) async {
    final sourcePath = await databasePath;
    final file = File(sourcePath);
    return file.copy(destinationPath);
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

  Future<void> restoreDatabase(String sourcePath) async {
    await closeDatabase();
    final destPath = await databasePath;
    final backupFile = File(sourcePath);
    await backupFile.copy(destPath);
    await database;
  }
}
