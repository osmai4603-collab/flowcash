import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_schema_manager.dart';
import 'package:flowcash/core/services/sqlite/sqlite_default_data.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';

void main() {
  print('=== STARTING SQLITE TRIGGERS INTEGRATION TEST ===');

  // Override sqlite3 library path for Linux VM
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  // 1. Initialize In-Memory Database
  final db = sqlite3.openInMemory();
  db.execute('PRAGMA foreign_keys = ON');

  print('Creating schema...');
  SqliteSchemaManager.createAll(db);

  print('Inserting defaults...');
  DefaultDataInserter.insertDefaults(db);

  // Helper assertions
  void assertEqual(dynamic actual, dynamic expected, String message) {
    if (actual != expected) {
      throw Exception('FAIL: $message. Expected $expected but got $actual');
    }
    print('PASS: $message ($actual)');
  }

  // 2. Setup Base Test Data (Accounts and Currency)
  print('\n=== SETTING UP MAIN & SUB ACCOUNTS ===');
  // Insert Main Account
  db.execute('''
    INSERT INTO ${MainAccountsTable().tableName} (
      ${MainAccountsTable().id}, ${MainAccountsTable().accountNumber}, ${MainAccountsTable().accountName}, 
      ${MainAccountsTable().currencyId}, ${MainAccountsTable().debitBalance}, ${MainAccountsTable().creditBalance}, 
      ${MainAccountsTable().mainAccountType}
    ) VALUES (1, '1000', 'الأصول والمصروفات', 'YER', 0.0, 0.0, 1)
  ''');

  // Insert Sub Accounts
  final nowStr = DateTime.now().toIso8601String();
  // Account 1: الصندوق
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (10, 'الصندوق', '1101', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Account 2: رأس المال
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (11, 'رأس المال', '1102', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Account 3: مخزون المواد (Income Stock)
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (12, 'مخزون المواد', '1103', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Account 4: تكلفة المبيعات (Outcome Stock)
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (13, 'تكلفة المبيعات', '1104', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Account 5: إيراد المبيعات (Revenue)
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (14, 'إيراد المبيعات', '1105', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Account 6: مصروف المبيعات (Expense)
  db.execute('''
    INSERT INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (15, 'مصروف المبيعات', '1106', 1, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  print('Accounts created successfully.');

  // ==========================================
  // SCENARIO 1: JournalItemsBalanceTrigger
  // ==========================================
  print('\n=== RUNNING SCENARIO 1: JournalItemsBalanceTrigger ===');

  // Insert a Journal Entry
  db.execute('''
    INSERT INTO ${JournalEntriesTable().tableName} (
      ${JournalEntriesTable().id}, ${JournalEntriesTable().referenceNumber}, ${JournalEntriesTable().description},
      ${JournalEntriesTable().createdAt}, ${JournalEntriesTable().userId}, ${JournalEntriesTable().currencyId},
      ${JournalEntriesTable().amount}, ${JournalEntriesTable().warehouseId}
    ) VALUES (100, 'JE-001', 'قيد تجريبي يدوي', '$nowStr', 1, 'YER', 1000.0, 1)
  ''');

  // Insert Journal Items
  print(
    'Inserting journal items (Debit 1000 to Box, Credit 1000 to Capital)...',
  );
  db.execute('''
    INSERT INTO ${JournalItemsTable().tableName} (
      ${JournalItemsTable().itemId}, ${JournalItemsTable().entryId}, ${JournalItemsTable().accountId},
      ${JournalItemsTable().amount}, ${JournalItemsTable().lineDescription}, ${JournalItemsTable().currencyId},
      ${JournalItemsTable().exPrice}, ${JournalItemsTable().exPriceMain}, ${JournalItemsTable().journalStatus}
    ) VALUES (200, 100, 10, 1000.0, 'مدين الصندوق', 'YER', 1.0, 1.0, 'increment')
  ''');

  db.execute('''
    INSERT INTO ${JournalItemsTable().tableName} (
      ${JournalItemsTable().itemId}, ${JournalItemsTable().entryId}, ${JournalItemsTable().accountId},
      ${JournalItemsTable().amount}, ${JournalItemsTable().lineDescription}, ${JournalItemsTable().currencyId},
      ${JournalItemsTable().exPrice}, ${JournalItemsTable().exPriceMain}, ${JournalItemsTable().journalStatus}
    ) VALUES (201, 100, 11, 1000.0, 'دائن رأس المال', 'YER', 1.0, 1.0, 'decrement')
  ''');

  // Verify balances are updated
  var rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 10',
      )
      .first;
  var rowSubCapital = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 11',
      )
      .first;
  var rowMain = db
      .select(
        'SELECT * FROM ${MainAccountsTable().tableName} WHERE ${MainAccountsTable().id} = 1',
      )
      .first;

  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    1000.0,
    'SubBox increment balance after insert',
  );
  assertEqual(
    rowSubBox[SubAccountsTable().decrementBalance],
    0.0,
    'SubBox decrement balance after insert',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().incrementBalance],
    0.0,
    'SubCapital increment balance after insert',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().decrementBalance],
    1000.0,
    'SubCapital decrement balance after insert',
  );
  assertEqual(
    rowMain[MainAccountsTable().debitBalance],
    1000.0,
    'Main account debit balance after insert',
  );
  assertEqual(
    rowMain[MainAccountsTable().creditBalance],
    1000.0,
    'Main account credit balance after insert',
  );

  // Update a journal item
  print('Updating journal item amount to 1500.0...');
  db.execute('''
    UPDATE ${JournalItemsTable().tableName}
    SET ${JournalItemsTable().amount} = 1500.0
    WHERE ${JournalItemsTable().itemId} = 200
  ''');

  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 10',
      )
      .first;
  rowMain = db
      .select(
        'SELECT * FROM ${MainAccountsTable().tableName} WHERE ${MainAccountsTable().id} = 1',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    1500.0,
    'SubBox increment balance after update',
  );
  assertEqual(
    rowMain[MainAccountsTable().debitBalance],
    1500.0,
    'Main account debit balance after update',
  );

  // Delete journal items
  print('Deleting journal items...');
  db.execute(
    'DELETE FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = 100',
  );

  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 10',
      )
      .first;
  rowSubCapital = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 11',
      )
      .first;
  rowMain = db
      .select(
        'SELECT * FROM ${MainAccountsTable().tableName} WHERE ${MainAccountsTable().id} = 1',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    0.0,
    'SubBox increment balance after delete',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().decrementBalance],
    0.0,
    'SubCapital decrement balance after delete',
  );
  assertEqual(
    rowMain[MainAccountsTable().debitBalance],
    0.0,
    'Main account debit balance after delete',
  );
  assertEqual(
    rowMain[MainAccountsTable().creditBalance],
    0.0,
    'Main account credit balance after delete',
  );

  // ==========================================
  // SCENARIO 2: InventoriesTrigger
  // ==========================================
  print('\n=== RUNNING SCENARIO 2: InventoriesTrigger ===');

  // Insert a Category
  db.execute('''
    INSERT INTO ${CategoriesTable().tableName} (
      ${CategoriesTable().id}, ${CategoriesTable().categoryType}, ${CategoriesTable().categoryName}, 
      ${CategoriesTable().categoryNumber}
    ) VALUES (50, 'material', 'إسمنت مقاوم', 'CAT-1001')
  ''');

  // Insert Inventory with costTotal = 5000.0
  print('Inserting new inventory item...');
  db.execute('''
    INSERT INTO ${InventoriesTable().tableName} (
      ${InventoriesTable().id}, ${InventoriesTable().categoryId}, ${InventoriesTable().storeId},
      ${InventoriesTable().propertyAccountId}, ${InventoriesTable().revenueAccountId}, ${InventoriesTable().expenseAccountId},
      ${InventoriesTable().incomeStockId}, ${InventoriesTable().outcomeStockId}, ${InventoriesTable().costTotal},
      ${InventoriesTable().countUnits}, ${InventoriesTable().userId}
    ) VALUES (300, 50, 1, 11, 14, 15, 12, 13, 5000.0, 100.0, 1)
  ''');

  // Verify journal entry and items are automatically inserted
  final jeCount =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INVCAT-300'],
          ).first['cnt']
          as int;
  assertEqual(
    jeCount,
    1,
    'Journal entries created automatically for inventory insert',
  );

  final jeId =
      db.select(
            'SELECT ${JournalEntriesTable().id} FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INVCAT-300'],
          ).first[JournalEntriesTable().id]
          as int;
  final jiCount =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?',
            [jeId],
          ).first['cnt']
          as int;
  assertEqual(
    jiCount,
    2,
    'Journal items created automatically for inventory insert',
  );

  // Check sub-account balances via triggers propagation
  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first; // Income stock (debit)
  rowSubCapital = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 11',
      )
      .first; // Property account (credit)
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    5000.0,
    'Income Stock subaccount increment balance',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().decrementBalance],
    5000.0,
    'Property Account subaccount decrement balance',
  );

  // Update Inventory costTotal to 8000.0
  print('Updating inventory costTotal to 8000.0...');
  db.execute('''
    UPDATE ${InventoriesTable().tableName}
    SET ${InventoriesTable().costTotal} = 8000.0
    WHERE ${InventoriesTable().id} = 300
  ''');

  // Verify Journal Entry amount and items are updated
  final jeAmount =
      db.select(
            'SELECT ${JournalEntriesTable().amount} FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().id} = ?',
            [jeId],
          ).first[JournalEntriesTable().amount]
          as double;
  assertEqual(jeAmount, 8000.0, 'Journal Entry amount updated automatically');

  // Check sub-account balances updated correctly
  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first;
  rowSubCapital = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 11',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    8000.0,
    'Income Stock subaccount increment balance after update',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().decrementBalance],
    8000.0,
    'Property Account subaccount decrement balance after update',
  );

  // Delete Inventory
  print('Deleting inventory item...');
  db.execute(
    'DELETE FROM ${InventoriesTable().tableName} WHERE ${InventoriesTable().id} = 300',
  );

  final jeCountDeleted =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INVCAT-300'],
          ).first['cnt']
          as int;
  final jiCountDeleted =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?',
            [jeId],
          ).first['cnt']
          as int;
  assertEqual(
    jeCountDeleted,
    0,
    'Journal entry deleted automatically on inventory deletion',
  );
  assertEqual(
    jiCountDeleted,
    0,
    'Journal items deleted automatically on inventory deletion',
  );

  // Verify balances reverted to 0
  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first;
  rowSubCapital = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 11',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    0.0,
    'Income Stock subaccount increment balance after deletion',
  );
  assertEqual(
    rowSubCapital[SubAccountsTable().decrementBalance],
    0.0,
    'Property Account subaccount decrement balance after deletion',
  );

  // ==========================================
  // SCENARIO 3: InventoryOrdersTrigger
  // ==========================================
  print('\n=== RUNNING SCENARIO 3: InventoryOrdersTrigger ===');

  // Re-insert inventory to link transaction order
  db.execute('''
    INSERT INTO ${InventoriesTable().tableName} (
      ${InventoriesTable().id}, ${InventoriesTable().categoryId}, ${InventoriesTable().storeId},
      ${InventoriesTable().propertyAccountId}, ${InventoriesTable().revenueAccountId}, ${InventoriesTable().expenseAccountId},
      ${InventoriesTable().incomeStockId}, ${InventoriesTable().outcomeStockId}, ${InventoriesTable().costTotal},
      ${InventoriesTable().countUnits}, ${InventoriesTable().userId}
    ) VALUES (300, 50, 1, 11, 14, 15, 12, 13, 0.0, 0.0, 1)
  ''');

  // Reset balances for clean verification
  db.execute(
    'UPDATE ${SubAccountsTable().tableName} SET ${SubAccountsTable().incrementBalance} = 0.0, ${SubAccountsTable().decrementBalance} = 0.0',
  );
  db.execute(
    'UPDATE ${MainAccountsTable().tableName} SET ${MainAccountsTable().debitBalance} = 0.0, ${MainAccountsTable().creditBalance} = 0.0',
  );

  // Insert Inventory Transaction (Header)
  print('Inserting inventory transaction (header)...');
  db.execute('''
    INSERT INTO ${InventoryTransactionsTable().tableName} (
      ${InventoryTransactionsTable().id}, ${InventoryTransactionsTable().createdAt}, ${InventoryTransactionsTable().createdBy},
      ${InventoryTransactionsTable().note}, ${InventoryTransactionsTable().warehouseId}, ${InventoryTransactionsTable().billNumber},
      ${InventoryTransactionsTable().transactionType}
    ) VALUES (400, '$nowStr', 1, 'حركة توريد مخزني مادة إسمنت', 1, 12345, 'inventory_receive')
  ''');

  // Insert Inventory Transaction Order (Detail) with transactionType 'inventory_receive' and 15 count units
  print('Inserting inventory transaction order (detail)...');
  db.execute('''
    INSERT INTO ${InventoryTransactionsOrdersTable().tableName} (
      ${InventoryTransactionsOrdersTable().id}, ${InventoryTransactionsOrdersTable().inventoryId},
      ${InventoryTransactionsOrdersTable().countUnits}, ${InventoryTransactionsOrdersTable().tranId},
    ) VALUES (500, 300, 15.0, 400, 'inventory_receive')
  ''');

  // Verify journal entry and items are automatically inserted for this order
  final orderJeCount =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INV-400'],
          ).first['cnt']
          as int;
  assertEqual(
    orderJeCount,
    1,
    'Journal entries created automatically for inventory transaction order insert',
  );

  final orderJeId =
      db.select(
            'SELECT ${JournalEntriesTable().id} FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INV-400'],
          ).first[JournalEntriesTable().id]
          as int;
  final orderJiCount =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?',
            [orderJeId],
          ).first['cnt']
          as int;
  assertEqual(
    orderJiCount,
    1,
    'Journal items created automatically for inventory transaction order insert',
  );

  // Verify journal item references the correct Income Stock account (12) and amount 15.0
  final orderJi = db.select(
    'SELECT * FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?',
    [orderJeId],
  ).first;
  assertEqual(
    orderJi[JournalItemsTable().accountId],
    12,
    'Journal item linked to correct Account ID (incomeStockId)',
  );
  assertEqual(
    orderJi[JournalItemsTable().amount],
    15.0,
    'Journal item amount correctly set from countUnits',
  );
  assertEqual(
    orderJi[JournalItemsTable().journalStatus],
    'increment',
    'Journal item status correctly set to increment',
  );

  // Verify balance propagated
  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    15.0,
    'Income Stock subaccount increment balance matches order countUnits',
  );

  // Update Inventory Transaction Order: countUnits to 25.0
  print('Updating inventory transaction order countUnits to 25.0...');
  db.execute('''
    UPDATE ${InventoryTransactionsOrdersTable().tableName}
    SET ${InventoryTransactionsOrdersTable().countUnits} = 25.0
    WHERE ${InventoryTransactionsOrdersTable().id} = 500
  ''');

  // Verify journal item and balances updated
  final updatedJi = db.select(
    'SELECT * FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?',
    [orderJeId],
  ).first;
  assertEqual(
    updatedJi[JournalItemsTable().amount],
    25.0,
    'Journal item amount updated to 25.0',
  );

  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    25.0,
    'Income Stock subaccount increment balance updated to 25.0',
  );

  // Delete Inventory Transaction Order
  print('Deleting inventory transaction order...');
  db.execute(
    'DELETE FROM ${InventoryTransactionsOrdersTable().tableName} WHERE ${InventoryTransactionsOrdersTable().id} = 500',
  );

  final orderJeCountDel =
      db.select(
            'SELECT COUNT(*) AS cnt FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} = ?',
            ['INV-400'],
          ).first['cnt']
          as int;
  assertEqual(
    orderJeCountDel,
    0,
    'Journal entries deleted automatically on order delete',
  );

  rowSubBox = db
      .select(
        'SELECT * FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} = 12',
      )
      .first;
  assertEqual(
    rowSubBox[SubAccountsTable().incrementBalance],
    0.0,
    'Income Stock subaccount balance reverted to 0.0 after order deletion',
  );

  print('\n=== ALL TRIGGERS COMPLETED AND VERIFIED SUCCESSFULLY ===');
  db.dispose();
}
