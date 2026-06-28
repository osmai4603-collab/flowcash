import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';

class WarehousesTableSqlite extends WarehousesTable implements SqliteTable {
  static final WarehousesTableSqlite _instance = WarehousesTableSqlite._internal();

  factory WarehousesTableSqlite() => _instance;

  WarehousesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${warehouseName} TEXT NOT NULL UNIQUE,
        ${location} TEXT,
        ${warehouseType} INTEGER NOT NULL,
        ${parentId} INTEGER
      )
  ''';
}
