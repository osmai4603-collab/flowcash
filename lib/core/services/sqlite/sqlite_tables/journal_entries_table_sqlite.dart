import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';

class JournalEntriesTableSqlite extends JournalEntriesTable implements SqliteTable {
  static final JournalEntriesTableSqlite _instance = JournalEntriesTableSqlite._internal();

  factory JournalEntriesTableSqlite() => _instance;

  JournalEntriesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${referenceNumber} TEXT NOT NULL,
        ${description} TEXT,
        ${createdAt} TEXT NOT NULL,
        ${userId} INTEGER NOT NULL,
        ${currencyId} TEXT NOT NULL,
        ${amount} REAL NOT NULL DEFAULT 0.0,
        ${warehouseId} INTEGER,
        FOREIGN KEY (${userId}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
