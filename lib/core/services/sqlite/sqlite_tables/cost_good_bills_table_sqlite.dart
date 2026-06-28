import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';

class CostGoodBillsTableSqlite extends CostGoodBillsTable implements SqliteTable {
  static final CostGoodBillsTableSqlite _instance = CostGoodBillsTableSqlite._internal();

  factory CostGoodBillsTableSqlite() => _instance;

  CostGoodBillsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${createdAt} TEXT NOT NULL,
        ${createdBy} INTEGER NOT NULL,
        ${note} TEXT,
        ${offerAmount} REAL NOT NULL,
        ${currencyId} TEXT NOT NULL,
        ${billNumber} INTEGER NOT NULL,
        ${warehouseId} INTEGER NOT NULL,
        ${journalEntryId} INTEGER,
        ${personId} INTEGER NOT NULL,
        ${billId} INTEGER NOT NULL,
        FOREIGN KEY (${createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${personId}) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${billId}) REFERENCES ${BillsTable().tableName} (${BillsTable().id}) ON DELETE CASCADE
      )
  ''';
}
