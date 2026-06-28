import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/values_table.dart';

class ValuesTableSqlite extends ValuesTable implements SqliteTable {
  static final ValuesTableSqlite _instance = ValuesTableSqlite._internal();

  factory ValuesTableSqlite() => _instance;

  ValuesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${valueType} TEXT NOT NULL,
        ${value} TEXT NOT NULL
      )
  ''';
}
