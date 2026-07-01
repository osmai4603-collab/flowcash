import 'dart:ffi';
import 'dart:io';
import 'package:flowcash/core/services/sqlite/sqlite_database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/home/osmsoftwareengineering/.local/share/flowcash';
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  // Ensure database directory exists
  Directory('/home/osmsoftwareengineering/.local/share/flowcash').createSync(recursive: true);

  print('=== STARTING DUMMY DATA INSERTION ON ACTIVE DATABASE ===');

  // Override sqlite3 library path for Linux VM
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  // Initialize active database (creates/opens cashing.db in Application Documents Directory)
  final db = await SqliteDatabaseManager.instance.database;

  print('Database initialized. Path: ${await SqliteDatabaseManager.instance.databasePath}');

  // Clean up old incorrect data
  print('Cleaning up old test data...');
  db.execute('DELETE FROM ${OpeningQuantitiesTable().tableName} WHERE ${OpeningQuantitiesTable().inventoryId} BETWEEN 1000 AND 1099 OR ${OpeningQuantitiesTable().inventoryId} = 900');
  db.execute('DELETE FROM ${InventoryTransactionsOrdersTable().tableName} WHERE id = 900');
  db.execute('DELETE FROM ${InventoryTransactionsTable().tableName} WHERE id = 900');
  db.execute('DELETE FROM ${InventoriesTable().tableName} WHERE ${InventoriesTable().id} BETWEEN 1000 AND 1099 OR ${InventoriesTable().id} = 900');
  db.execute('DELETE FROM ${JournalItemsTable().tableName} WHERE account_id BETWEEN 800 AND 906');
  db.execute('DELETE FROM ${JournalEntriesTable().tableName} WHERE reference_number LIKE "INVCAT-%" OR reference_number LIKE "INV-%"');
  db.execute('DELETE FROM ${SubAccountsTable().tableName} WHERE ${SubAccountsTable().id} BETWEEN 800 AND 906');
  db.execute('DELETE FROM ${MainAccountsTable().tableName} WHERE ${MainAccountsTable().id} IN (80, 90)');

  // 1. Setup Base Accounts
  print('Inserting Main Accounts and Sub Accounts...');
  db.execute('''
    INSERT OR IGNORE INTO ${MainAccountsTable().tableName} (
      ${MainAccountsTable().id}, ${MainAccountsTable().accountNumber}, ${MainAccountsTable().accountName}, 
      ${MainAccountsTable().currencyId}, ${MainAccountsTable().debitBalance}, ${MainAccountsTable().creditBalance}, 
      ${MainAccountsTable().mainAccountType}
    ) VALUES (90, '9000', 'حسابات تجريبية مخزنية', 'YER', 0.0, 0.0, 1)
  ''');

  final nowStr = DateTime.now().toIso8601String();

  // Sub Account 901: الصندوق التجريبي
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (901, 'الصندوق التجريبي', '9101', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Sub Account 902: رأس المال التجريبي
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (902, 'رأس المال التجريبي', '9102', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Sub Account 903: مخزون المواد التجريبي (Income Stock)
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (903, 'مخزون المواد التجريبي', '9103', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Sub Account 904: تكلفة المبيعات التجريبية (Outcome Stock)
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (904, 'تكلفة المبيعات التجريبية', '9104', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Sub Account 905: إيراد المبيعات التجريبي (Revenue)
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (905, 'إيراد المبيعات التجريبي', '9105', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // Sub Account 906: مصروف المبيعات التجريبي (Expense)
  db.execute('''
    INSERT OR IGNORE INTO ${SubAccountsTable().tableName} (
      ${SubAccountsTable().id}, ${SubAccountsTable().accountName}, ${SubAccountsTable().accountNumber}, 
      ${SubAccountsTable().mainAccountId}, ${SubAccountsTable().currencyId}, ${SubAccountsTable().incrementBalance}, 
      ${SubAccountsTable().decrementBalance}, ${SubAccountsTable().subAccountType}, ${SubAccountsTable().createdAt}
    ) VALUES (906, 'مصروف المبيعات التجريبي', '9106', 90, 'YER', 0.0, 0.0, 1, '$nowStr')
  ''');

  // 2. Insert Category
  print('Inserting category...');
  db.execute('''
    INSERT OR IGNORE INTO ${CategoriesTable().tableName} (
      ${CategoriesTable().id}, ${CategoriesTable().categoryType}, ${CategoriesTable().categoryName}, 
      ${CategoriesTable().categoryNumber}
    ) VALUES (90, 'material', 'إسمنت مقاوم تجريبي', 'CAT-9090')
  ''');

  // 3. Insert Inventory Item (triggers automatic JournalEntry and JournalItems)
  print('Inserting inventory item (this triggers automatic journal entries)...');
  db.execute('''
    INSERT OR IGNORE INTO ${InventoriesTable().tableName} (
      ${InventoriesTable().id}, ${InventoriesTable().categoryId}, ${InventoriesTable().storeId},
      ${InventoriesTable().propertyAccountId}, ${InventoriesTable().revenueAccountId}, ${InventoriesTable().expenseAccountId},
      ${InventoriesTable().incomeStockId}, ${InventoriesTable().outcomeStockId}, ${InventoriesTable().costTotal},
      ${InventoriesTable().countUnits}, ${InventoriesTable().userId}
    ) VALUES (900, 90, 1, 902, 905, 906, 903, 904, 15000.0, 150.0, 1)
  ''');

  // 4. Insert Inventory Transaction
  print('Inserting inventory transaction (header)...');
  db.execute('''
    INSERT OR IGNORE INTO ${InventoryTransactionsTable().tableName} (
      ${InventoryTransactionsTable().id}, ${InventoryTransactionsTable().createdAt}, ${InventoryTransactionsTable().createdBy},
      ${InventoryTransactionsTable().note}, ${InventoryTransactionsTable().warehouseId}, ${InventoryTransactionsTable().billNumber},
      ${InventoryTransactionsTable().transactionType}
    ) VALUES (900, '$nowStr', 1, 'توريد مخزني تجريبي لتجربة Triggers', 1, 998877, 'inventory_receive')
  ''');

  // 5. Insert Inventory Transaction Order (triggers automatic JournalEntry and JournalItem)
  print('Inserting inventory transaction order (detail)...');
  db.execute('''
    INSERT OR IGNORE INTO ${InventoryTransactionsOrdersTable().tableName} (
      ${InventoryTransactionsOrdersTable().id}, ${InventoryTransactionsOrdersTable().inventoryId},
      ${InventoryTransactionsOrdersTable().countUnits}, ${InventoryTransactionsOrdersTable().tranId},
    ) VALUES (900, 900, 35.0, 900, 'inventory_receive')
  ''');

  // 6. Verification query
  print('\n=== VERIFYING AUTOMATIC JOURNAL ENTRIES GENERATED ===');
  final entries = db.select('SELECT * FROM ${JournalEntriesTable().tableName} WHERE ${JournalEntriesTable().referenceNumber} LIKE ?', ['%900']);
  for (final row in entries) {
    print('Journal Entry: ${row[JournalEntriesTable().referenceNumber]} - ${row[JournalEntriesTable().description]} - Amount: ${row[JournalEntriesTable().amount]} YER');
    final items = db.select('SELECT * FROM ${JournalItemsTable().tableName} WHERE ${JournalItemsTable().entryId} = ?', [row[JournalEntriesTable().id]]);
    for (final item in items) {
      print('  -> Journal Item: Account: ${item[JournalItemsTable().accountId]}, Amount: ${item[JournalItemsTable().amount]}, Status: ${item[JournalItemsTable().journalStatus]}');
    }
  }

  print('\n=== DUMMY DATA INSERTION COMPLETE AND VERIFIED ===');
}
