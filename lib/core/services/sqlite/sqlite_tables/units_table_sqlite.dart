import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/units_table.dart';

class UnitsTableSqlite extends UnitsTable implements SqliteTable {
  static final UnitsTableSqlite _instance = UnitsTableSqlite._internal();

  factory UnitsTableSqlite() => _instance;

  UnitsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${unitType} TEXT NOT NULL,
        ${unitName} TEXT NOT NULL,
        ${length} REAL NOT NULL DEFAULT 0.0,
        ${width} REAL NOT NULL DEFAULT 0.0,
        ${thickness} REAL NOT NULL DEFAULT 0.0,
        UNIQUE(${unitType}, ${unitName}, ${length}, ${width}, ${thickness})
      )
  ''';
}
