import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/warehouse_values_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';

class WarehouseValuesTableSqlite extends WarehouseValuesTable implements SqliteTable {
  static final WarehouseValuesTableSqlite _instance = WarehouseValuesTableSqlite._internal();

  factory WarehouseValuesTableSqlite() => _instance;

  WarehouseValuesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${warehouseId} INTEGER NOT NULL,
        ${valueType} TEXT NOT NULL,
        ${value} TEXT,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE CASCADE
      )
  ''';
}
