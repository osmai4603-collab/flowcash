import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';

class ProgramUsersTableSqlite extends ProgramUsersTable implements SqliteTable {
  static final ProgramUsersTableSqlite _instance = ProgramUsersTableSqlite._internal();

  factory ProgramUsersTableSqlite() => _instance;

  ProgramUsersTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${userName} TEXT NOT NULL,
        ${password} TEXT NOT NULL,
        ${userType} INTEGER NOT NULL,
        ${warehouseId} INTEGER NOT NULL,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
