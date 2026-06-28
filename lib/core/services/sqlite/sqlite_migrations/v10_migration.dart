import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';

class V10Migration extends SqliteMigration {
  @override
  int get version => 10;

  @override
  void execute(Database db) {
    // Drop deprecated triggers that reference inventory_transactions to prevent migration failure
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_delete_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_delete_journal');

    db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_transactions_new (
        ${InventoryTransactionsTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsTable().createdAt} TEXT NOT NULL,
        ${InventoryTransactionsTable().createdBy} INTEGER NOT NULL,
        ${InventoryTransactionsTable().note} TEXT,
        ${InventoryTransactionsTable().warehouseId} INTEGER NOT NULL,
        ${InventoryTransactionsTable().personId} INTEGER,
        ${InventoryTransactionsTable().billNumber} INTEGER NOT NULL,
        ${InventoryTransactionsTable().transactionType} TEXT NOT NULL CHECK(${InventoryTransactionsTable().transactionType} IN (${InventoryTransactionType.values.map((e) => "'${e.name}'").join(', ')})),
        FOREIGN KEY (${InventoryTransactionsTable().personId}) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${InventoryTransactionsTable().warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${InventoryTransactionsTable().createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    db.execute('''
      INSERT INTO inventory_transactions_new (
        ${InventoryTransactionsTable().id},
        ${InventoryTransactionsTable().createdAt},
        ${InventoryTransactionsTable().createdBy},
        ${InventoryTransactionsTable().note},
        ${InventoryTransactionsTable().warehouseId},
        ${InventoryTransactionsTable().personId},
        ${InventoryTransactionsTable().billNumber},
        ${InventoryTransactionsTable().transactionType}
      )
      SELECT
        ${InventoryTransactionsTable().id},
        ${InventoryTransactionsTable().createdAt},
        ${InventoryTransactionsTable().createdBy},
        ${InventoryTransactionsTable().note},
        ${InventoryTransactionsTable().warehouseId},
        ${InventoryTransactionsTable().personId},
        ${InventoryTransactionsTable().billNumber},
        CASE 
          WHEN ${InventoryTransactionsTable().transactionType} = 'inventory_receive' THEN 'import_inventory'
          WHEN ${InventoryTransactionsTable().transactionType} = 'inventory_delivery' THEN 'export_inventory'
          ELSE ${InventoryTransactionsTable().transactionType}
        END
      FROM ${InventoryTransactionsTable().tableName}
    ''');

    db.execute('DROP TABLE ${InventoryTransactionsTable().tableName}');
    db.execute('ALTER TABLE inventory_transactions_new RENAME TO ${InventoryTransactionsTable().tableName}');
  }
}
