import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class V6Migration extends SqliteMigration {
  @override
  int get version => 6;

  @override
  void execute(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillsTable().tableName} (
        ${CostGoodBillsTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillsTable().createdAt} TEXT NOT NULL,
        ${CostGoodBillsTable().createdBy} INTEGER NOT NULL,
        ${CostGoodBillsTable().note} TEXT,
        ${CostGoodBillsTable().offerAmount} REAL NOT NULL,
        ${CostGoodBillsTable().currencyId} TEXT NOT NULL,
        ${CostGoodBillsTable().billNumber} INTEGER NOT NULL,
        ${CostGoodBillsTable().warehouseId} INTEGER NOT NULL,
        ${CostGoodBillsTable().journalEntryId} INTEGER,
        ${CostGoodBillsTable().personId} INTEGER NOT NULL,
        ${CostGoodBillsTable().billId} INTEGER NOT NULL,
        FOREIGN KEY (${CostGoodBillsTable().createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable().currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable().warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable().personId}) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${CostGoodBillsTable().billId}) REFERENCES ${BillsTable().tableName} (${BillsTable().id}) ON DELETE CASCADE
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillOrdersTable().tableName} (
        ${CostGoodBillOrdersTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillOrdersTable().billId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable().categoryId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable().countUnits} REAL NOT NULL DEFAULT 0.0,
        ${CostGoodBillOrdersTable().totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${CostGoodBillOrdersTable().billId}) REFERENCES ${CostGoodBillsTable().tableName} (${CostGoodBillsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${CostGoodBillOrdersTable().categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE RESTRICT
      )
    ''');

    db.execute(
      'ALTER TABLE ${BillsTable().tableName} ADD COLUMN ${BillsTable().costGoodId} INTEGER REFERENCES ${CostGoodBillsTable().tableName} (${CostGoodBillsTable().id}) ON DELETE SET NULL',
    );
  }
}
