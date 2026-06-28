import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/hints_table.dart';

class HintsTableSqlite extends HintsTable implements SqliteTable {
  static final HintsTableSqlite _instance = HintsTableSqlite._internal();

  factory HintsTableSqlite() => _instance;

  HintsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${hintName} TEXT NOT NULL,
        ${hintType} TEXT NOT NULL,
        UNIQUE(${hintType}, ${hintName})
      )
  ''';
}
