import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';

class BillsTableSqlite extends BillsTable implements SqliteTable {
  static final BillsTableSqlite _instance = BillsTableSqlite._internal();

  factory BillsTableSqlite() => _instance;

  BillsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable =>
      '''
CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $createdAt TEXT NOT NULL,
        $createdBy INTEGER NOT NULL,
        $note TEXT,
        $offerAmount REAL NOT NULL,
        $currencyId TEXT NOT NULL,
        $billNumber INTEGER NOT NULL,
        $warehouseId INTEGER NOT NULL,
        $journalEntryId INTEGER,
        $personId INTEGER NOT NULL,
        $inventoryTransactionId INTEGER,
        $isCash INTEGER NOT NULL DEFAULT 0,
        $billType TEXT NOT NULL,
        $costGoodId INTEGER,
        $treasuryId INTEGER,
        FOREIGN KEY ($createdBy) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY ($currencyId) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY ($warehouseId) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY ($personId) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY ($inventoryTransactionId) REFERENCES ${InventoryTransactionsTable().tableName} (${InventoryTransactionsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY ($costGoodId) REFERENCES ${CostGoodBillsTable().tableName} (${CostGoodBillsTable().id}) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY ($treasuryId) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY ($journalEntryId) REFERENCES ${JournalEntriesTable().tableName} (${JournalEntriesTable().id}) ON UPDATE CASCADE ON DELETE SET NULL,
        CHECK (
          ($isCash = 1 AND $treasuryId IS NOT NULL) OR
          ($isCash = 0 AND $treasuryId IS NULL)
        )
      )
  ''';
}
