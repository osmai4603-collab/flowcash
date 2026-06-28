import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';

class V11Migration extends SqliteMigration {
  @override
  int get version => 11;

  @override
  void execute(Database db) {
    // Recreate inventory_transactions_orders to drop the obsolete tran_type column
    db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_transactions_orders_new (
        ${InventoryTransactionsOrdersTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsOrdersTable().inventoryId} INTEGER,
        ${InventoryTransactionsOrdersTable().countUnits} REAL NOT NULL DEFAULT 0.0,
        ${InventoryTransactionsOrdersTable().tranId} INTEGER NOT NULL,
        FOREIGN KEY (${InventoryTransactionsOrdersTable().inventoryId}) REFERENCES ${InventoriesTable().tableName} (${InventoriesTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${InventoryTransactionsOrdersTable().tranId}) REFERENCES ${InventoryTransactionsTable().tableName} (${InventoryTransactionsTable().id}) ON DELETE CASCADE
      )
    ''');

    db.execute('''
      INSERT INTO inventory_transactions_orders_new (
        ${InventoryTransactionsOrdersTable().id},
        ${InventoryTransactionsOrdersTable().inventoryId},
        ${InventoryTransactionsOrdersTable().countUnits},
        ${InventoryTransactionsOrdersTable().tranId}
      )
      SELECT
        ${InventoryTransactionsOrdersTable().id},
        ${InventoryTransactionsOrdersTable().inventoryId},
        ${InventoryTransactionsOrdersTable().countUnits},
        ${InventoryTransactionsOrdersTable().tranId}
      FROM ${InventoryTransactionsOrdersTable().tableName}
    ''');

    db.execute('DROP TABLE ${InventoryTransactionsOrdersTable().tableName}');
    db.execute('ALTER TABLE inventory_transactions_orders_new RENAME TO ${InventoryTransactionsOrdersTable().tableName}');
  }
}
