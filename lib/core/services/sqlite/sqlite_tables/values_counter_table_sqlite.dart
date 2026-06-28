import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';

class ValuesCounterTableSqlite extends ValuesCounterTable implements SqliteTable {
  static final ValuesCounterTableSqlite _instance = ValuesCounterTableSqlite._internal();

  factory ValuesCounterTableSqlite() => _instance;

  ValuesCounterTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${counterType} TEXT NOT NULL UNIQUE,
        ${count} INTEGER NOT NULL,
        ${counterMax} INTEGER NOT NULL DEFAULT 99999,
        ${incrementValue} INTEGER NOT NULL DEFAULT 1,
        ${formatValue} INTEGER NOT NULL DEFAULT 5
      )
  ''';
}
