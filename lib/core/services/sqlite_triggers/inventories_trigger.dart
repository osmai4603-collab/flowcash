import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';

/// Creates SQLite triggers for managing journal entries and items
/// when inventories are inserted, updated, or deleted.
final class InventoriesTrigger {
  const InventoriesTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS inventories_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_delete_journal');

    // 1. Insert Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventories_after_insert_journal
      AFTER INSERT ON ${InventoriesTable.tableName}
      BEGIN
        -- Insert journal entry
        INSERT INTO ${JournalEntriesTable.tableName} (
          ${JournalEntriesTable.referenceNumber},
          ${JournalEntriesTable.description},
          ${JournalEntriesTable.createdAt},
          ${JournalEntriesTable.userId},
          ${JournalEntriesTable.currencyId},
          ${JournalEntriesTable.amount},
          ${JournalEntriesTable.warehouseId}
        ) VALUES (
          'INVCAT-' || NEW.${InventoriesTable.id},
          'قيد تلقائي لتهيئة المخزون رقم ' || NEW.${InventoriesTable.id},
          datetime('now', 'localtime'),
          NEW.${InventoriesTable.userId},
          'YER',
          NEW.${InventoriesTable.costTotal},
          NEW.${InventoriesTable.storeId}
        );

        -- Insert journal item for Income Stock Account (Debit / Increment)
        INSERT INTO ${JournalItemsTable.tableName} (
          ${JournalItemsTable.entryId},
          ${JournalItemsTable.accountId},
          ${JournalItemsTable.amount},
          ${JournalItemsTable.lineDescription},
          ${JournalItemsTable.currencyId},
          ${JournalItemsTable.exPrice},
          ${JournalItemsTable.expriceMain},
          ${JournalItemsTable.journalStatus}
        ) SELECT 
          e.${JournalEntriesTable.entryId},
          NEW.${InventoriesTable.incomeStockId},
          NEW.${InventoriesTable.costTotal},
          'بند مدين تلقائي - حساب المخزون',
          'YER',
          1.0,
          1.0,
          'increment'
        FROM ${JournalEntriesTable.tableName} e
        WHERE e.${JournalEntriesTable.referenceNumber} = 'INVCAT-' || NEW.${InventoriesTable.id};

        -- Insert journal item for Property Account (Credit / Decrement)
        INSERT INTO ${JournalItemsTable.tableName} (
          ${JournalItemsTable.entryId},
          ${JournalItemsTable.accountId},
          ${JournalItemsTable.amount},
          ${JournalItemsTable.lineDescription},
          ${JournalItemsTable.currencyId},
          ${JournalItemsTable.exPrice},
          ${JournalItemsTable.expriceMain},
          ${JournalItemsTable.journalStatus}
        ) SELECT 
          e.${JournalEntriesTable.entryId},
          NEW.${InventoriesTable.propertyAccountId},
          NEW.${InventoriesTable.costTotal},
          'بند دائن تلقائي - حساب رأس المال',
          'YER',
          1.0,
          1.0,
          'decrement'
        FROM ${JournalEntriesTable.tableName} e
        WHERE e.${JournalEntriesTable.referenceNumber} = 'INVCAT-' || NEW.${InventoriesTable.id};
      END;
    ''');

    // 2. Update Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventories_after_update_journal
      AFTER UPDATE ON ${InventoriesTable.tableName}
      WHEN OLD.${InventoriesTable.costTotal} != NEW.${InventoriesTable.costTotal} 
        OR OLD.${InventoriesTable.propertyAccountId} != NEW.${InventoriesTable.propertyAccountId}
        OR OLD.${InventoriesTable.incomeStockId} != NEW.${InventoriesTable.incomeStockId}
      BEGIN
        -- Update journal entry amount
        UPDATE ${JournalEntriesTable.tableName}
        SET ${JournalEntriesTable.amount} = NEW.${InventoriesTable.costTotal}
        WHERE ${JournalEntriesTable.referenceNumber} = 'INVCAT-' || OLD.${InventoriesTable.id};

        -- Update journal items (debit and credit)
        UPDATE ${JournalItemsTable.tableName}
        SET ${JournalItemsTable.amount} = NEW.${InventoriesTable.costTotal},
            ${JournalItemsTable.accountId} = CASE 
              WHEN ${JournalItemsTable.journalStatus} = 'increment' 
              THEN NEW.${InventoriesTable.incomeStockId} 
              ELSE NEW.${InventoriesTable.propertyAccountId} 
            END
        WHERE ${JournalItemsTable.entryId} = (
          SELECT ${JournalEntriesTable.entryId} 
          FROM ${JournalEntriesTable.tableName}
          WHERE ${JournalEntriesTable.referenceNumber} = 'INVCAT-' || OLD.${InventoriesTable.id}
        );
      END;
    ''');

    // 3. Delete Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS inventories_after_delete_journal
      AFTER DELETE ON ${InventoriesTable.tableName}
      BEGIN
        -- Delete journal items first
        DELETE FROM ${JournalItemsTable.tableName}
        WHERE ${JournalItemsTable.entryId} = (
          SELECT ${JournalEntriesTable.entryId} 
          FROM ${JournalEntriesTable.tableName}
          WHERE ${JournalEntriesTable.referenceNumber} = 'INVCAT-' || OLD.${InventoriesTable.id}
        );

        -- Delete journal entry
        DELETE FROM ${JournalEntriesTable.tableName}
        WHERE ${JournalEntriesTable.referenceNumber} = 'INVCAT-' || OLD.${InventoriesTable.id};
      END;
    ''');
  }
}
