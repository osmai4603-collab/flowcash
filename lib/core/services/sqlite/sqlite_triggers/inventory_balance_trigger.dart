import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

/// Creates SQLite triggers for managing inventory quantities (count_units)
/// when inventory transactions orders are inserted, updated, or deleted.
final class InventoryBalanceTrigger {
  const InventoryBalanceTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_insert_balance');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_update_balance');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_delete_balance');

    // 1. Insert Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_insert_balance
      AFTER INSERT ON ${InventoryTransactionsOrdersTable().tableName}
      BEGIN
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().countUnits} = ${InventoriesTable().countUnits} + (
          CASE 
            WHEN (SELECT ${InventoryTransactionsTable().transactionType} FROM ${InventoryTransactionsTable().tableName} WHERE ${InventoryTransactionsTable().id} = NEW.${InventoryTransactionsOrdersTable().tranId}) = 'import_inventory' 
            THEN NEW.${InventoryTransactionsOrdersTable().countUnits}
            ELSE -NEW.${InventoryTransactionsOrdersTable().countUnits}
          END
        )
        WHERE ${InventoriesTable().id} = NEW.${InventoryTransactionsOrdersTable().inventoryId};
      END;
    ''');

    // 2. Update Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_update_balance
      AFTER UPDATE ON ${InventoryTransactionsOrdersTable().tableName}
      BEGIN
        -- Reverse old value
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().countUnits} = ${InventoriesTable().countUnits} - (
          CASE 
            WHEN (SELECT ${InventoryTransactionsTable().transactionType} FROM ${InventoryTransactionsTable().tableName} WHERE ${InventoryTransactionsTable().id} = OLD.${InventoryTransactionsOrdersTable().tranId}) = 'import_inventory' 
            THEN OLD.${InventoryTransactionsOrdersTable().countUnits}
            ELSE -OLD.${InventoryTransactionsOrdersTable().countUnits}
          END
        )
        WHERE ${InventoriesTable().id} = OLD.${InventoryTransactionsOrdersTable().inventoryId};

        -- Apply new value
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().countUnits} = ${InventoriesTable().countUnits} + (
          CASE 
            WHEN (SELECT ${InventoryTransactionsTable().transactionType} FROM ${InventoryTransactionsTable().tableName} WHERE ${InventoryTransactionsTable().id} = NEW.${InventoryTransactionsOrdersTable().tranId}) = 'import_inventory' 
            THEN NEW.${InventoryTransactionsOrdersTable().countUnits}
            ELSE -NEW.${InventoryTransactionsOrdersTable().countUnits}
          END
        )
        WHERE ${InventoriesTable().id} = NEW.${InventoryTransactionsOrdersTable().inventoryId};
      END;
    ''');

    // 3. Delete Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_delete_balance
      AFTER DELETE ON ${InventoryTransactionsOrdersTable().tableName}
      BEGIN
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().countUnits} = ${InventoriesTable().countUnits} - (
          CASE 
            WHEN (SELECT ${InventoryTransactionsTable().transactionType} FROM ${InventoryTransactionsTable().tableName} WHERE ${InventoryTransactionsTable().id} = OLD.${InventoryTransactionsOrdersTable().tranId}) = 'import_inventory' 
            THEN OLD.${InventoryTransactionsOrdersTable().countUnits}
            ELSE -OLD.${InventoryTransactionsOrdersTable().countUnits}
          END
        )
        WHERE ${InventoriesTable().id} = OLD.${InventoryTransactionsOrdersTable().inventoryId};
      END;
    ''');
  }
}
