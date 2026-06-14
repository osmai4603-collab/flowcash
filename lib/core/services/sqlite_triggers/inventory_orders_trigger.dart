import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';

/// Creates SQLite triggers for managing journal entries and items
/// when inventory transactions orders are inserted, updated, or deleted.
final class InventoryOrdersTrigger {
  const InventoryOrdersTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventory_orders_after_delete_journal');

    // 1. Insert Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_insert_journal
      AFTER INSERT ON ${InventoryTransactionsOrdersTable.tableName}
      BEGIN
        -- Insert journal entry if it does not exist for this transaction
        INSERT OR IGNORE INTO ${JournalEntriesTable.tableName} (
          ${JournalEntriesTable.referenceNumber},
          ${JournalEntriesTable.description},
          ${JournalEntriesTable.createdAt},
          ${JournalEntriesTable.userId},
          ${JournalEntriesTable.currencyId},
          ${JournalEntriesTable.amount},
          ${JournalEntriesTable.warehouseId}
        )
        SELECT 
          'INV-' || NEW.${InventoryTransactionsOrdersTable.tranId},
          'قيد تلقائي للحركة المخزنية رقم ' || NEW.${InventoryTransactionsOrdersTable.tranId},
          t.${InventoryTransactionsTable.createdAt},
          t.${InventoryTransactionsTable.createdBy},
          'YER',
          NEW.${InventoryTransactionsOrdersTable.countUnits} * 1.0,
          t.${InventoryTransactionsTable.warehouseId}
        FROM ${InventoryTransactionsTable.tableName} t
        WHERE t.${InventoryTransactionsTable.id} = NEW.${InventoryTransactionsOrdersTable.tranId}
        AND NOT EXISTS (
          SELECT 1 FROM ${JournalEntriesTable.tableName} 
          WHERE ${JournalEntriesTable.referenceNumber} = 'INV-' || NEW.${InventoryTransactionsOrdersTable.tranId}
        );

        -- Insert journal item matching the inventory stock account
        INSERT INTO ${JournalItemsTable.tableName} (
          ${JournalItemsTable.entryId},
          ${JournalItemsTable.accountId},
          ${JournalItemsTable.amount},
          ${JournalItemsTable.lineDescription},
          ${JournalItemsTable.currencyId},
          ${JournalItemsTable.exPrice},
          ${JournalItemsTable.expriceMain},
          ${JournalItemsTable.journalStatus}
        )
        SELECT 
          e.${JournalEntriesTable.entryId},
          CASE 
            WHEN NEW.${InventoryTransactionsOrdersTable.transactionType} = 'inventory_receive' 
            THEN inv.${InventoriesTable.incomeStockId}
            ELSE inv.${InventoriesTable.outcomeStockId}
          END,
          NEW.${InventoryTransactionsOrdersTable.countUnits} * 1.0,
          'بند مخزني تلقائي للمادة رقم ' || NEW.${InventoryTransactionsOrdersTable.inventoryId},
          'YER',
          1.0,
          1.0,
          CASE 
            WHEN NEW.${InventoryTransactionsOrdersTable.transactionType} = 'inventory_receive' 
            THEN 'increment' 
            ELSE 'decrement' 
          END
        FROM ${JournalEntriesTable.tableName} e
        JOIN ${InventoriesTable.tableName} inv ON inv.${InventoriesTable.id} = NEW.${InventoryTransactionsOrdersTable.inventoryId}
        WHERE e.${JournalEntriesTable.referenceNumber} = 'INV-' || NEW.${InventoryTransactionsOrdersTable.tranId};
      END;
    ''');

    // 2. Update Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_update_journal
      AFTER UPDATE ON ${InventoryTransactionsOrdersTable.tableName}
      BEGIN
        UPDATE ${JournalItemsTable.tableName}
        SET ${JournalItemsTable.amount} = NEW.${InventoryTransactionsOrdersTable.countUnits} * 1.0,
            ${JournalItemsTable.accountId} = CASE 
              WHEN NEW.${InventoryTransactionsOrdersTable.transactionType} = 'inventory_receive' 
              THEN (SELECT ${InventoriesTable.incomeStockId} FROM ${InventoriesTable.tableName} WHERE ${InventoriesTable.id} = NEW.${InventoryTransactionsOrdersTable.inventoryId})
              ELSE (SELECT ${InventoriesTable.outcomeStockId} FROM ${InventoriesTable.tableName} WHERE ${InventoriesTable.id} = NEW.${InventoryTransactionsOrdersTable.inventoryId})
            END,
            ${JournalItemsTable.journalStatus} = CASE 
              WHEN NEW.${InventoryTransactionsOrdersTable.transactionType} = 'inventory_receive' 
              THEN 'increment' 
              ELSE 'decrement' 
            END
        WHERE ${JournalItemsTable.entryId} = (
          SELECT ${JournalEntriesTable.entryId} FROM ${JournalEntriesTable.tableName}
          WHERE ${JournalEntriesTable.referenceNumber} = 'INV-' || OLD.${InventoryTransactionsOrdersTable.tranId}
        );
      END;
    ''');

    // 3. Delete Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventory_orders_after_delete_journal
      AFTER DELETE ON ${InventoryTransactionsOrdersTable.tableName}
      BEGIN
        DELETE FROM ${JournalItemsTable.tableName}
        WHERE ${JournalItemsTable.entryId} = (
          SELECT ${JournalEntriesTable.entryId} FROM ${JournalEntriesTable.tableName}
          WHERE ${JournalEntriesTable.referenceNumber} = 'INV-' || OLD.${InventoryTransactionsOrdersTable.tranId}
        );

        DELETE FROM ${JournalEntriesTable.tableName}
        WHERE ${JournalEntriesTable.referenceNumber} = 'INV-' || OLD.${InventoryTransactionsOrdersTable.tranId}
        AND NOT EXISTS (
          SELECT 1 FROM ${JournalItemsTable.tableName} 
          WHERE ${JournalItemsTable.entryId} = ${JournalEntriesTable.tableName}.${JournalEntriesTable.entryId}
        );
      END;
    ''');
  }
}
