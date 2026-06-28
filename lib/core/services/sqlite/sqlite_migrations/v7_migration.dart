import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';

class V7Migration extends SqliteMigration {
  @override
  int get version => 7;

  @override
  void execute(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS bills_new (
        ${BillsTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillsTable().createdAt} TEXT NOT NULL,
        ${BillsTable().createdBy} INTEGER NOT NULL,
        ${BillsTable().note} TEXT,
        ${BillsTable().offerAmount} REAL NOT NULL,
        ${BillsTable().currencyId} TEXT NOT NULL,
        ${BillsTable().billNumber} INTEGER NOT NULL,
        ${BillsTable().warehouseId} INTEGER NOT NULL,
        ${BillsTable().journalEntryId} INTEGER,
        ${BillsTable().personId} INTEGER NOT NULL,
        ${BillsTable().inventoryTransactionId} INTEGER,
        ${BillsTable().isCash} INTEGER NOT NULL DEFAULT 0,
        ${BillsTable().billType} TEXT NOT NULL,
        ${BillsTable().costGoodId} INTEGER,
        ${BillsTable().treasuryId} INTEGER,
        CHECK (
          (${BillsTable().isCash} = 1 AND ${BillsTable().treasuryId} IS NOT NULL) OR
          (${BillsTable().isCash} = 0 AND ${BillsTable().treasuryId} IS NULL)
        ),
        FOREIGN KEY (${BillsTable().createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable().currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable().warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable().personId}) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable().inventoryTransactionId}) REFERENCES ${InventoryTransactionsTable().tableName} (${InventoryTransactionsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable().costGoodId}) REFERENCES ${CostGoodBillsTable().tableName} (${CostGoodBillsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable().treasuryId}) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL
      )
    ''');

    db.execute('''
      INSERT INTO bills_new (
        ${BillsTable().id},
        ${BillsTable().createdAt},
        ${BillsTable().createdBy},
        ${BillsTable().note},
        ${BillsTable().offerAmount},
        ${BillsTable().currencyId},
        ${BillsTable().billNumber},
        ${BillsTable().warehouseId},
        ${BillsTable().journalEntryId},
        ${BillsTable().personId},
        ${BillsTable().inventoryTransactionId},
        ${BillsTable().isCash},
        ${BillsTable().billType},
        ${BillsTable().costGoodId},
        ${BillsTable().treasuryId}
      )
      SELECT
        ${BillsTable().id},
        ${BillsTable().createdAt},
        ${BillsTable().createdBy},
        ${BillsTable().note},
        ${BillsTable().offerAmount},
        ${BillsTable().currencyId},
        ${BillsTable().billNumber},
        ${BillsTable().warehouseId},
        ${BillsTable().journalEntryId},
        ${BillsTable().personId},
        ${BillsTable().inventoryTransactionId},
        0,
        ${BillsTable().billType},
        ${BillsTable().costGoodId},
        NULL
      FROM ${BillsTable().tableName}
    ''');

    db.execute('DROP TABLE ${BillsTable().tableName}');
    db.execute(
      'ALTER TABLE bills_new RENAME TO ${BillsTable().tableName}',
    );
  }
}
