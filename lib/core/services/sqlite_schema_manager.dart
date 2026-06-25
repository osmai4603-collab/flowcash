import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';
import 'package:flowcash/core/tables/hints_table.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/tables/financial_bonds_table.dart';
import 'package:flowcash/core/tables/financial_transactions_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/services/sqlite_triggers/journal_items_balance_trigger.dart';
import 'package:flowcash/core/services/sqlite_triggers/inventory_orders_trigger.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/core/tables/goods_costs_table.dart';
import 'package:flowcash/core/tables/assets_transactions_table.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'package:flowcash/core/tables/warehouse_values_table.dart';

final class SqliteSchemaManager {
  const SqliteSchemaManager._();

  static const int currentVersion = 9;

  /// Create the full schema for a new database.
  static void createAll(Database db) {
    _createAllTables(db);
    _createTriggers(db);
  }

  /// Apply incremental migrations from [fromVersion] (exclusive) up to [toVersion] (inclusive).
  static void migrate(Database db, int fromVersion, int toVersion) {
    if (fromVersion >= toVersion) return;
    db.execute('PRAGMA foreign_keys = OFF');
    try {
      for (var v = fromVersion + 1; v <= toVersion; v++) {
        db.execute('BEGIN');
        try {
          switch (v) {
            case 2:
              _applyV2Migration(db);
              break;
            case 3:
              _applyV3Migration(db);
              break;
            case 4:
              _applyV4Migration(db);
              break;
            case 5:
              _applyV5Migration(db);
              break;
            case 6:
              _applyV6Migration(db);
              break;
            case 7:
              _applyV7Migration(db);
              break;
            case 8:
              _applyV8Migration(db);
              break;
            case 9:
              _applyV9Migration(db);
              break;
            default:
              throw StateError('No migration defined for version $v');
          }
          db.execute('COMMIT');
          debugPrint('Migration to version $v applied');
        } catch (e) {
          db.execute('ROLLBACK');
          debugPrint('Migration to version $v failed: $e');
          rethrow;
        }
      }
    } finally {
      db.execute('PRAGMA foreign_keys = ON');
    }
  }

  static void _applyV2Migration(Database db) {
    // Add property_id column to inventories table
    db.execute(
      'ALTER TABLE ${InventoriesTable.tableName} ADD COLUMN ${InventoriesTable.propertyAccountId} INTEGER NOT NULL DEFAULT 0',
    );
  }

  static void _applyV3Migration(Database db) {
    // Add user_id column to inventories table
    db.execute(
      'ALTER TABLE ${InventoriesTable.tableName} ADD COLUMN ${InventoriesTable.userId} INTEGER NOT NULL DEFAULT 1',
    );
    // Recreate triggers to ensure the new InventoriesTrigger is added
    _createTriggers(db);
  }

  static void _applyV4Migration(Database db) {
    // Recreate subcategories table with the correct foreign key constraint to main_categories
    db.execute('''
      CREATE TABLE IF NOT EXISTS subcategories_new (
        ${SubcategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubcategoriesTable.mainCategoryId} INTEGER,
        ${SubcategoriesTable.catalogName} TEXT NOT NULL,
        ${SubcategoriesTable.catalogNumber} TEXT,
        UNIQUE (${SubcategoriesTable.catalogName}, ${SubcategoriesTable.mainCategoryId}),
        FOREIGN KEY (${SubcategoriesTable.mainCategoryId}) REFERENCES ${MainCategoriesTable.tableName} (${MainCategoriesTable.id}) ON DELETE SET NULL
      )
    ''');

    db.execute('''
      INSERT INTO subcategories_new (
        ${SubcategoriesTable.id},
        ${SubcategoriesTable.mainCategoryId},
        ${SubcategoriesTable.catalogName},
        ${SubcategoriesTable.catalogNumber}
      )
      SELECT 
        ${SubcategoriesTable.id},
        ${SubcategoriesTable.mainCategoryId},
        ${SubcategoriesTable.catalogName},
        ${SubcategoriesTable.catalogNumber}
      FROM ${SubcategoriesTable.tableName}
    ''');

    db.execute('DROP TABLE ${SubcategoriesTable.tableName}');
    db.execute(
      'ALTER TABLE subcategories_new RENAME TO ${SubcategoriesTable.tableName}',
    );
  }

  static void _applyV5Migration(Database db) {
    // Recreate categories table to add subcategory_id and its foreign key constraint
    db.execute('''
      CREATE TABLE IF NOT EXISTS categories_new (
        ${CategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesTable.categoryType} TEXT NOT NULL,
        ${CategoriesTable.categoryName} TEXT NOT NULL,
        ${CategoriesTable.categoryNumber} TEXT NOT NULL,
        ${CategoriesTable.barcode} TEXT,
        ${CategoriesTable.categoryUnitId} INTEGER,
        ${CategoriesTable.pricingUnitId} INTEGER,
        ${CategoriesTable.inventoryUnitId} INTEGER,
        ${CategoriesTable.subcategoryId} INTEGER,
        FOREIGN KEY (${CategoriesTable.categoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.pricingUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.inventoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.subcategoryId}) REFERENCES ${SubcategoriesTable.tableName} (${SubcategoriesTable.id}) ON DELETE SET NULL
      )
    ''');

    db.execute('''
      INSERT INTO categories_new (
        ${CategoriesTable.id},
        ${CategoriesTable.categoryType},
        ${CategoriesTable.categoryName},
        ${CategoriesTable.categoryNumber},
        ${CategoriesTable.barcode},
        ${CategoriesTable.categoryUnitId},
        ${CategoriesTable.pricingUnitId},
        ${CategoriesTable.inventoryUnitId}
      )
      SELECT 
        ${CategoriesTable.id},
        ${CategoriesTable.categoryType},
        ${CategoriesTable.categoryName},
        ${CategoriesTable.categoryNumber},
        ${CategoriesTable.barcode},
        ${CategoriesTable.categoryUnitId},
        ${CategoriesTable.pricingUnitId},
        ${CategoriesTable.inventoryUnitId}
      FROM ${CategoriesTable.tableName}
    ''');

    db.execute('DROP TABLE ${CategoriesTable.tableName}');
    db.execute(
      'ALTER TABLE categories_new RENAME TO ${CategoriesTable.tableName}',
    );
  }

  static void _applyV6Migration(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillsTable.tableName} (
        ${CostGoodBillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillsTable.createdAt} TEXT NOT NULL,
        ${CostGoodBillsTable.createdBy} INTEGER NOT NULL,
        ${CostGoodBillsTable.note} TEXT,
        ${CostGoodBillsTable.offerAmount} REAL NOT NULL,
        ${CostGoodBillsTable.currencyId} TEXT NOT NULL,
        ${CostGoodBillsTable.billNumber} INTEGER NOT NULL,
        ${CostGoodBillsTable.warehouseId} INTEGER NOT NULL,
        ${CostGoodBillsTable.journalEntryId} INTEGER,
        ${CostGoodBillsTable.personId} INTEGER NOT NULL,
        ${CostGoodBillsTable.billId} INTEGER NOT NULL,
        FOREIGN KEY (${CostGoodBillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${CostGoodBillsTable.billId}) REFERENCES ${BillsTable.tableName} (${BillsTable.id}) ON DELETE CASCADE
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillOrdersTable.tableName} (
        ${CostGoodBillOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillOrdersTable.billId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable.categoryId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${CostGoodBillOrdersTable.totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${CostGoodBillOrdersTable.billId}) REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${CostGoodBillOrdersTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    db.execute(
      'ALTER TABLE ${BillsTable.tableName} ADD COLUMN ${BillsTable.costGoodId} INTEGER REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE SET NULL',
    );
  }

  static void _applyV7Migration(Database db) {
    // Recreate bills table to add treasury_id with CHECK constraint
    db.execute('''
      CREATE TABLE IF NOT EXISTS bills_new (
        ${BillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillsTable.createdAt} TEXT NOT NULL,
        ${BillsTable.createdBy} INTEGER NOT NULL,
        ${BillsTable.note} TEXT,
        ${BillsTable.offerAmount} REAL NOT NULL,
        ${BillsTable.currencyId} TEXT NOT NULL,
        ${BillsTable.billNumber} INTEGER NOT NULL,
        ${BillsTable.warehouseId} INTEGER NOT NULL,
        ${BillsTable.journalEntryId} INTEGER,
        ${BillsTable.personId} INTEGER NOT NULL,
        ${BillsTable.inventoryTransactionId} INTEGER,
        ${BillsTable.isCash} INTEGER NOT NULL DEFAULT 0,
        ${BillsTable.billType} TEXT NOT NULL,
        ${BillsTable.costGoodId} INTEGER,
        ${BillsTable.treasuryId} INTEGER,
        CHECK (
          (${BillsTable.isCash} = 1 AND ${BillsTable.treasuryId} IS NOT NULL) OR
          (${BillsTable.isCash} = 0 AND ${BillsTable.treasuryId} IS NULL)
        ),
        FOREIGN KEY (${BillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.inventoryTransactionId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.costGoodId}) REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.treasuryId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL
      )
    ''');

    // Copy existing data (treasury_id will be NULL for all existing rows)
    // First, update existing cash bills to have is_cash = 0 temporarily to pass CHECK
    // Or we can just set treasury_id to NULL and relax the constraint during migration
    // Since foreign_keys are OFF during migration, we handle this by copying data as-is
    // Existing cash bills will need treasury assignment after migration
    db.execute('''
      INSERT INTO bills_new (
        ${BillsTable.id},
        ${BillsTable.createdAt},
        ${BillsTable.createdBy},
        ${BillsTable.note},
        ${BillsTable.offerAmount},
        ${BillsTable.currencyId},
        ${BillsTable.billNumber},
        ${BillsTable.warehouseId},
        ${BillsTable.journalEntryId},
        ${BillsTable.personId},
        ${BillsTable.inventoryTransactionId},
        ${BillsTable.isCash},
        ${BillsTable.billType},
        ${BillsTable.costGoodId},
        ${BillsTable.treasuryId}
      )
      SELECT
        ${BillsTable.id},
        ${BillsTable.createdAt},
        ${BillsTable.createdBy},
        ${BillsTable.note},
        ${BillsTable.offerAmount},
        ${BillsTable.currencyId},
        ${BillsTable.billNumber},
        ${BillsTable.warehouseId},
        ${BillsTable.journalEntryId},
        ${BillsTable.personId},
        ${BillsTable.inventoryTransactionId},
        0,
        ${BillsTable.billType},
        ${BillsTable.costGoodId},
        NULL
      FROM ${BillsTable.tableName}
    ''');

    db.execute('DROP TABLE ${BillsTable.tableName}');
    db.execute(
      'ALTER TABLE bills_new RENAME TO ${BillsTable.tableName}',
    );
  }

  static void _applyV9Migration(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CategoriesAttributesTable.tableName} (
        ${CategoriesAttributesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesAttributesTable.categoryId} INTEGER NOT NULL,
        ${CategoriesAttributesTable.subcategoryUnitId} INTEGER NOT NULL,
        FOREIGN KEY (${CategoriesAttributesTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${CategoriesAttributesTable.subcategoryUnitId}) REFERENCES ${SubcategoriesUnitsTable.tableName} (${SubcategoriesUnitsTable.id}) ON DELETE CASCADE
      )
    ''');
  }

  static void _applyV8Migration(Database db) {
    // Recreate bills table to add journal_entry_id foreign key constraint
    db.execute('''
      CREATE TABLE IF NOT EXISTS bills_new (
        ${BillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillsTable.createdAt} TEXT NOT NULL,
        ${BillsTable.createdBy} INTEGER NOT NULL,
        ${BillsTable.note} TEXT,
        ${BillsTable.offerAmount} REAL NOT NULL,
        ${BillsTable.currencyId} TEXT NOT NULL,
        ${BillsTable.billNumber} INTEGER NOT NULL,
        ${BillsTable.warehouseId} INTEGER NOT NULL,
        ${BillsTable.journalEntryId} INTEGER,
        ${BillsTable.personId} INTEGER NOT NULL,
        ${BillsTable.inventoryTransactionId} INTEGER,
        ${BillsTable.isCash} INTEGER NOT NULL DEFAULT 0,
        ${BillsTable.billType} TEXT NOT NULL,
        ${BillsTable.costGoodId} INTEGER,
        ${BillsTable.treasuryId} INTEGER,
        FOREIGN KEY (${BillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.inventoryTransactionId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.costGoodId}) REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.treasuryId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.journalEntryId}) REFERENCES ${JournalEntriesTable.tableName} (${JournalEntriesTable.id}) ON UPDATE CASCADE ON DELETE CASCADE,
        CHECK (
          (${BillsTable.isCash} = 1 AND ${BillsTable.treasuryId} IS NOT NULL) OR
          (${BillsTable.isCash} = 0 AND ${BillsTable.treasuryId} IS NULL)
        )
      )
    ''');

    db.execute('''
      INSERT INTO bills_new (
        ${BillsTable.id},
        ${BillsTable.createdAt},
        ${BillsTable.createdBy},
        ${BillsTable.note},
        ${BillsTable.offerAmount},
        ${BillsTable.currencyId},
        ${BillsTable.billNumber},
        ${BillsTable.warehouseId},
        ${BillsTable.journalEntryId},
        ${BillsTable.personId},
        ${BillsTable.inventoryTransactionId},
        ${BillsTable.isCash},
        ${BillsTable.billType},
        ${BillsTable.costGoodId},
        ${BillsTable.treasuryId}
      )
      SELECT
        ${BillsTable.id},
        ${BillsTable.createdAt},
        ${BillsTable.createdBy},
        ${BillsTable.note},
        ${BillsTable.offerAmount},
        ${BillsTable.currencyId},
        ${BillsTable.billNumber},
        ${BillsTable.warehouseId},
        ${BillsTable.journalEntryId},
        ${BillsTable.personId},
        ${BillsTable.inventoryTransactionId},
        ${BillsTable.isCash},
        ${BillsTable.billType},
        ${BillsTable.costGoodId},
        ${BillsTable.treasuryId}
      FROM ${BillsTable.tableName}
    ''');

    db.execute('DROP TABLE ${BillsTable.tableName}');
    db.execute(
      'ALTER TABLE bills_new RENAME TO ${BillsTable.tableName}',
    );
  }

  // ---------------------------------------------------------------------------
  // Schema creation – all tables with their final structure
  // ---------------------------------------------------------------------------
  static void _createAllTables(Database db) {
    // 1. Currencies
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CurrenciesTable.tableName} (
        ${CurrenciesTable.id} TEXT PRIMARY KEY,
        ${CurrenciesTable.currencyName} TEXT NOT NULL,
        ${CurrenciesTable.symbol} TEXT NOT NULL,
        ${CurrenciesTable.isDefault} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Exchange Prices
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${ExchangePricesTable.tableName} (
        ${ExchangePricesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${ExchangePricesTable.fromCurrencyId} TEXT NOT NULL,
        ${ExchangePricesTable.toCurrencyId} TEXT NOT NULL,
        ${ExchangePricesTable.exchangePrice} REAL NOT NULL,
        FOREIGN KEY (${ExchangePricesTable.fromCurrencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${ExchangePricesTable.toCurrencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE CASCADE
      )
    ''');

    // 3. Warehouses
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${WarehousesTable.tableName} (
        ${WarehousesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${WarehousesTable.warehouseName} TEXT NOT NULL UNIQUE,
        ${WarehousesTable.location} TEXT,
        ${WarehousesTable.warehouseType} INTEGER NOT NULL,
        ${WarehousesTable.parentId} INTEGER
      )
    ''');

    // 4. Main Accounts
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${MainAccountsTable.tableName} (
        ${MainAccountsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${MainAccountsTable.accountNumber} TEXT NOT NULL UNIQUE,
        ${MainAccountsTable.accountName} TEXT NOT NULL UNIQUE,
        ${MainAccountsTable.currencyId} TEXT NOT NULL,
        ${MainAccountsTable.debitBalance} REAL NOT NULL DEFAULT 0.0,
        ${MainAccountsTable.creditBalance} REAL NOT NULL DEFAULT 0.0,
        ${MainAccountsTable.mainAccountType} INTEGER NOT NULL,
        ${MainAccountsTable.numbersCounter} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${MainAccountsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 5. Sub Accounts
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${SubAccountsTable.tableName} (
        ${SubAccountsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubAccountsTable.accountName} TEXT NOT NULL UNIQUE,
        ${SubAccountsTable.accountNumber} TEXT NOT NULL UNIQUE,
        ${SubAccountsTable.mainAccountId} INTEGER NOT NULL,
        ${SubAccountsTable.currencyId} TEXT NOT NULL,
        ${SubAccountsTable.incrementBalance} REAL NOT NULL DEFAULT 0.0,
        ${SubAccountsTable.decrementBalance} REAL NOT NULL DEFAULT 0.0,
        ${SubAccountsTable.balanceMax} REAL DEFAULT NULL,
        ${SubAccountsTable.subAccountType} INTEGER NOT NULL,
        ${SubAccountsTable.createdAt} TEXT NOT NULL,
        FOREIGN KEY (${SubAccountsTable.mainAccountId}) REFERENCES ${MainAccountsTable.tableName} (${MainAccountsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${SubAccountsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 6. Persons
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${PersonsTable.tableName} (
        ${PersonsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${PersonsTable.personName} TEXT NOT NULL,
        ${PersonsTable.phoneNumber} TEXT,
        ${PersonsTable.address} TEXT,
        ${PersonsTable.email} TEXT,
        ${PersonsTable.personType} INTEGER NOT NULL,
        ${PersonsTable.receivableAccountId} INTEGER,
        ${PersonsTable.payableAccountId} INTEGER,
        ${PersonsTable.createdAt} TEXT,
        UNIQUE (${PersonsTable.personName}, ${PersonsTable.personType}),
        FOREIGN KEY (${PersonsTable.receivableAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY (${PersonsTable.payableAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE SET NULL
      )
    ''');

    // 7. Accounting Periods
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${AccountingPeriodsTable.tableName} (
        ${AccountingPeriodsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${AccountingPeriodsTable.balance} REAL NOT NULL DEFAULT 0.0,
        ${AccountingPeriodsTable.currencyId} TEXT NOT NULL,
        ${AccountingPeriodsTable.lastPeriodId} INTEGER,
        ${AccountingPeriodsTable.periodName} TEXT NOT NULL UNIQUE,
        ${AccountingPeriodsTable.dateOfStartPeriod} TEXT NOT NULL UNIQUE,
        ${AccountingPeriodsTable.dateOfEndPeriod} TEXT,
        ${AccountingPeriodsTable.inventoryType} TEXT,
        FOREIGN KEY (${AccountingPeriodsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${AccountingPeriodsTable.lastPeriodId}) REFERENCES ${AccountingPeriodsTable.tableName} (${AccountingPeriodsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 8. Hints
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${HintsTable.tableName} (
        ${HintsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${HintsTable.hintName} TEXT NOT NULL,
        ${HintsTable.hintType} TEXT NOT NULL,
        UNIQUE(${HintsTable.hintType}, ${HintsTable.hintName})
      )
    ''');

    // 9. Values Counter
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${ValuesCounterTable.tableName} (
        ${ValuesCounterTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${ValuesCounterTable.counterType} TEXT NOT NULL UNIQUE,
        ${ValuesCounterTable.count} INTEGER NOT NULL,
        ${ValuesCounterTable.counterMax} INTEGER NOT NULL DEFAULT 99999,
        ${ValuesCounterTable.incrementValue} INTEGER NOT NULL DEFAULT 1,
        ${ValuesCounterTable.formatValue} INTEGER NOT NULL DEFAULT 5
      )
    ''');

    // 10. Program Users
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${ProgramUsersTable.tableName} (
        ${ProgramUsersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${ProgramUsersTable.userName} TEXT NOT NULL,
        ${ProgramUsersTable.password} TEXT NOT NULL,
        ${ProgramUsersTable.userType} INTEGER NOT NULL,
        ${ProgramUsersTable.warehouseId} INTEGER NOT NULL,
        FOREIGN KEY (${ProgramUsersTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 11. Financial Bonds
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${FinancialBondsTable.tableName} (
        ${FinancialBondsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${FinancialBondsTable.createdAt} TEXT NOT NULL,
        ${FinancialBondsTable.createdBy} INTEGER NOT NULL,
        ${FinancialBondsTable.note} TEXT,
        ${FinancialBondsTable.offerAmount} REAL NOT NULL CHECK(${FinancialBondsTable.offerAmount} > 0),
        ${FinancialBondsTable.currencyId} TEXT NOT NULL,
        ${FinancialBondsTable.billNumber} INTEGER NOT NULL CHECK(${FinancialBondsTable.billNumber} > 0),
        ${FinancialBondsTable.warehouseId} INTEGER NOT NULL,
        ${FinancialBondsTable.journalEntryId} INTEGER,
        ${FinancialBondsTable.hintId} INTEGER NOT NULL,
        ${FinancialBondsTable.bondType} TEXT NOT NULL CHECK(${FinancialBondsTable.bondType} IN ('proceeds', 'paids')),
        FOREIGN KEY (${FinancialBondsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.hintId}) REFERENCES ${HintsTable.tableName} (${HintsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 12. Financial Transactions
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${FinancialTransactionsTable.tableName} (
        ${FinancialTransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${FinancialTransactionsTable.createdAt} TEXT NOT NULL,
        ${FinancialTransactionsTable.createdBy} INTEGER NOT NULL,
        ${FinancialTransactionsTable.note} TEXT,
        ${FinancialTransactionsTable.offerAmount} REAL NOT NULL CHECK(${FinancialTransactionsTable.offerAmount} > 0),
        ${FinancialTransactionsTable.currencyId} TEXT NOT NULL,
        ${FinancialTransactionsTable.billNumber} INTEGER NOT NULL CHECK(${FinancialTransactionsTable.billNumber} > 0),
        ${FinancialTransactionsTable.warehouseId} INTEGER NOT NULL,
        ${FinancialTransactionsTable.journalEntryId} INTEGER,
        ${FinancialTransactionsTable.hintId} INTEGER NOT NULL,
        ${FinancialTransactionsTable.transactionType} TEXT NOT NULL CHECK(${FinancialTransactionsTable.transactionType} IN ('revenues', 'expenses')),
        FOREIGN KEY (${FinancialTransactionsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialTransactionsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialTransactionsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialTransactionsTable.hintId}) REFERENCES ${HintsTable.tableName} (${HintsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 13. Categories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CategoriesTable.tableName} (
        ${CategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesTable.categoryType} TEXT NOT NULL,
        ${CategoriesTable.categoryName} TEXT NOT NULL,
        ${CategoriesTable.categoryNumber} TEXT NOT NULL,
        ${CategoriesTable.barcode} TEXT,
        ${CategoriesTable.categoryUnitId} INTEGER,
        ${CategoriesTable.pricingUnitId} INTEGER,
        ${CategoriesTable.inventoryUnitId} INTEGER,
        ${CategoriesTable.subcategoryId} INTEGER,
        FOREIGN KEY (${CategoriesTable.categoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.pricingUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.inventoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.subcategoryId}) REFERENCES ${SubcategoriesTable.tableName} (${SubcategoriesTable.id}) ON DELETE SET NULL
      )
    ''');

    // 14. Subcategories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${SubcategoriesTable.tableName} (
        ${SubcategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubcategoriesTable.mainCategoryId} INTEGER,
        ${SubcategoriesTable.catalogName} TEXT NOT NULL,
        ${SubcategoriesTable.catalogNumber} TEXT,
        UNIQUE (${SubcategoriesTable.catalogName}, ${SubcategoriesTable.mainCategoryId}),
        FOREIGN KEY (${SubcategoriesTable.mainCategoryId}) REFERENCES ${MainCategoriesTable.tableName} (${MainCategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 15. Inventories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoriesTable.tableName} (
        ${InventoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoriesTable.categoryId} INTEGER NOT NULL,
        ${InventoriesTable.storeId} INTEGER NOT NULL,
        ${InventoriesTable.propertyAccountId} INTEGER NOT NULL DEFAULT 0,
        ${InventoriesTable.revenueAccountId} INTEGER NOT NULL,
        ${InventoriesTable.expenseAccountId} INTEGER NOT NULL,
        ${InventoriesTable.incomeStockId} INTEGER NOT NULL,
        ${InventoriesTable.outcomeStockId} INTEGER NOT NULL,
        ${InventoriesTable.costTotal} REAL NOT NULL DEFAULT 0.0,
        ${InventoriesTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${InventoriesTable.userId} INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (${InventoriesTable.storeId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.propertyAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.revenueAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.expenseAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.incomeStockId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.outcomeStockId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${InventoriesTable.userId}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 16. Inventory Transactions
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoryTransactionsTable.tableName} (
        ${InventoryTransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsTable.createdAt} TEXT NOT NULL,
        ${InventoryTransactionsTable.createdBy} INTEGER NOT NULL,
        ${InventoryTransactionsTable.note} TEXT,
        ${InventoryTransactionsTable.warehouseId} INTEGER NOT NULL,
        ${InventoryTransactionsTable.personId} INTEGER,
        ${InventoryTransactionsTable.billNumber} INTEGER NOT NULL,
        ${InventoryTransactionsTable.transactionType} TEXT NOT NULL CHECK(${InventoryTransactionsTable.transactionType} IN (${InventoryTransactionType.values.map((e) => "'${e.name}'").join(', ')})),
        FOREIGN KEY (${InventoryTransactionsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${InventoryTransactionsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${InventoryTransactionsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 17. Inventory Transactions Orders
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoryTransactionsOrdersTable.tableName} (
        ${InventoryTransactionsOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsOrdersTable.inventoryId} INTEGER,
        ${InventoryTransactionsOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${InventoryTransactionsOrdersTable.tranId} INTEGER NOT NULL,
        ${InventoryTransactionsOrdersTable.transactionType} TEXT NOT NULL CHECK(${InventoryTransactionsOrdersTable.transactionType} IN (${InventoryTransactionType.values.map((e) => "'${e.name}'").join(', ')})),
        FOREIGN KEY (${InventoryTransactionsOrdersTable.inventoryId}) REFERENCES ${InventoriesTable.tableName} (${InventoriesTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${InventoryTransactionsOrdersTable.tranId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE CASCADE
      )
    ''');

    // 18. Opening Quantities
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${OpeningQuantitiesTable.tableName} (
        ${OpeningQuantitiesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${OpeningQuantitiesTable.inventoryId} INTEGER NOT NULL,
        ${OpeningQuantitiesTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${OpeningQuantitiesTable.createdAt} TEXT NOT NULL,
        ${OpeningQuantitiesTable.costTotal} REAL NOT NULL DEFAULT 0.0,
        ${OpeningQuantitiesTable.periodId} INTEGER NOT NULL,
        ${OpeningQuantitiesTable.currencyId} TEXT NOT NULL,
        ${OpeningQuantitiesTable.journalEntryId} INTEGER,
        FOREIGN KEY (${OpeningQuantitiesTable.inventoryId}) REFERENCES ${InventoriesTable.tableName} (${InventoriesTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${OpeningQuantitiesTable.periodId}) REFERENCES ${AccountingPeriodsTable.tableName} (${AccountingPeriodsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${OpeningQuantitiesTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${OpeningQuantitiesTable.journalEntryId}) REFERENCES ${JournalEntriesTable.tableName} (${JournalEntriesTable.id}) ON DELETE SET NULL,
        UNIQUE (${OpeningQuantitiesTable.inventoryId}, ${OpeningQuantitiesTable.periodId})
      )
    ''');

    // 19. Main Categories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${MainCategoriesTable.tableName} (
        ${MainCategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${MainCategoriesTable.categoryName} TEXT NOT NULL,
        ${MainCategoriesTable.unitType} TEXT NOT NULL,
        ${MainCategoriesTable.categoryType} TEXT NOT NULL,
        ${MainCategoriesTable.unitName} TEXT NOT NULL
      )
    ''');

    // 20. Category Properties
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CategoryPropertiesTable.tableName} (
        ${CategoryPropertiesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoryPropertiesTable.mainCategoryId} INTEGER NOT NULL,
        ${CategoryPropertiesTable.propertyName} TEXT NOT NULL,
        ${CategoryPropertiesTable.unitType} TEXT NOT NULL,
        ${CategoryPropertiesTable.isSingle} INTEGER NOT NULL DEFAULT 0,
        ${CategoryPropertiesTable.isCategoryUnit} INTEGER NOT NULL DEFAULT 0,
        ${CategoryPropertiesTable.isPricingUnit} INTEGER NOT NULL DEFAULT 0,
        ${CategoryPropertiesTable.isInventoryUnit} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${CategoryPropertiesTable.mainCategoryId}) REFERENCES ${MainCategoriesTable.tableName} (${MainCategoriesTable.id}) ON DELETE CASCADE
      )
    ''');

    // 21. Units
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${UnitsTable.tableName} (
        ${UnitsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${UnitsTable.unitType} TEXT NOT NULL,
        ${UnitsTable.unitName} TEXT NOT NULL,
        ${UnitsTable.length} REAL NOT NULL DEFAULT 0.0,
        ${UnitsTable.width} REAL NOT NULL DEFAULT 0.0,
        ${UnitsTable.thickness} REAL NOT NULL DEFAULT 0.0,
        UNIQUE(${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness})
      )
    ''');

    // 22. Subcategories Units (Catalog Infos)
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${SubcategoriesUnitsTable.tableName} (
        ${SubcategoriesUnitsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubcategoriesUnitsTable.subcategoryId} INTEGER NOT NULL,
        ${SubcategoriesUnitsTable.unitId} INTEGER NOT NULL,
        ${SubcategoriesUnitsTable.propertyId} INTEGER NOT NULL,
        FOREIGN KEY (${SubcategoriesUnitsTable.subcategoryId}) REFERENCES ${SubcategoriesTable.tableName} (${SubcategoriesTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${SubcategoriesUnitsTable.propertyId}) REFERENCES ${CategoryPropertiesTable.tableName} (${CategoryPropertiesTable.id}),
        FOREIGN KEY (${SubcategoriesUnitsTable.unitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON DELETE CASCADE
      )
    ''');

    // 23. Bills
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${BillsTable.tableName} (
        ${BillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillsTable.createdAt} TEXT NOT NULL,
        ${BillsTable.createdBy} INTEGER NOT NULL,
        ${BillsTable.note} TEXT,
        ${BillsTable.offerAmount} REAL NOT NULL,
        ${BillsTable.currencyId} TEXT NOT NULL,
        ${BillsTable.billNumber} INTEGER NOT NULL,
        ${BillsTable.warehouseId} INTEGER NOT NULL,
        ${BillsTable.journalEntryId} INTEGER,
        ${BillsTable.personId} INTEGER NOT NULL,
        ${BillsTable.inventoryTransactionId} INTEGER,
        ${BillsTable.isCash} INTEGER NOT NULL DEFAULT 0,
        ${BillsTable.billType} TEXT NOT NULL,
        ${BillsTable.costGoodId} INTEGER,
        ${BillsTable.treasuryId} INTEGER,
        FOREIGN KEY (${BillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.inventoryTransactionId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.costGoodId}) REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.treasuryId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.journalEntryId}) REFERENCES ${JournalEntriesTable.tableName} (${JournalEntriesTable.id}) ON UPDATE CASCADE ON DELETE CASCADE,
        CHECK (
          (${BillsTable.isCash} = 1 AND ${BillsTable.treasuryId} IS NOT NULL) OR
          (${BillsTable.isCash} = 0 AND ${BillsTable.treasuryId} IS NULL)
        )
      )
    ''');

    // 24. Bill Orders
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${BillOrdersTable.tableName} (
        ${BillOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillOrdersTable.billId} INTEGER NOT NULL,
        ${BillOrdersTable.categoryId} INTEGER NOT NULL,
        ${BillOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${BillOrdersTable.totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${BillOrdersTable.billId}) REFERENCES ${BillsTable.tableName} (${BillsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${BillOrdersTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 25. Goods Costs
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${GoodsCostsTable.tableName} (
        ${GoodsCostsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${GoodsCostsTable.createdAt} TEXT NOT NULL,
        ${GoodsCostsTable.createdBy} INTEGER NOT NULL,
        ${GoodsCostsTable.note} TEXT,
        ${GoodsCostsTable.offerAmount} REAL NOT NULL,
        ${GoodsCostsTable.currencyId} TEXT NOT NULL,
        ${GoodsCostsTable.billNumber} INTEGER NOT NULL,
        ${GoodsCostsTable.warehouseId} INTEGER NOT NULL,
        ${GoodsCostsTable.journalEntryId} INTEGER,
        ${GoodsCostsTable.hintId} INTEGER NOT NULL,
        ${GoodsCostsTable.orderId} INTEGER,
        ${GoodsCostsTable.historyGroup} TEXT,
        FOREIGN KEY (${GoodsCostsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${GoodsCostsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${GoodsCostsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${GoodsCostsTable.hintId}) REFERENCES ${HintsTable.tableName} (${HintsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${GoodsCostsTable.orderId}) REFERENCES ${BillOrdersTable.tableName} (${BillOrdersTable.id}) ON DELETE SET NULL
      )
    ''');

    // 26. Assets Transactions
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${AssetsTransactionsTable.tableName} (
        ${AssetsTransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${AssetsTransactionsTable.createdAt} TEXT NOT NULL,
        ${AssetsTransactionsTable.createdBy} INTEGER NOT NULL,
        ${AssetsTransactionsTable.note} TEXT,
        ${AssetsTransactionsTable.offerAmount} REAL NOT NULL,
        ${AssetsTransactionsTable.currencyId} TEXT NOT NULL,
        ${AssetsTransactionsTable.billNumber} INTEGER NOT NULL,
        ${AssetsTransactionsTable.warehouseId} INTEGER NOT NULL,
        ${AssetsTransactionsTable.journalEntryId} INTEGER,
        ${AssetsTransactionsTable.hintId} INTEGER NOT NULL,
        ${AssetsTransactionsTable.historyGroup} TEXT,
        FOREIGN KEY (${AssetsTransactionsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${AssetsTransactionsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${AssetsTransactionsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${AssetsTransactionsTable.hintId}) REFERENCES ${HintsTable.tableName} (${HintsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 27. Warehouse Values
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${WarehouseValuesTable.tableName} (
        ${WarehouseValuesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${WarehouseValuesTable.warehouseId} INTEGER NOT NULL,
        ${WarehouseValuesTable.valueType} TEXT NOT NULL,
        ${WarehouseValuesTable.value} TEXT,
        FOREIGN KEY (${WarehouseValuesTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE CASCADE
      )
    ''');

    // 28. Values
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${ValuesTable.tableName} (
        ${ValuesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${ValuesTable.valueType} TEXT NOT NULL,
        ${ValuesTable.value} TEXT NOT NULL
      )
    ''');

    // 29. Journal Entries
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${JournalEntriesTable.tableName} (
        ${JournalEntriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${JournalEntriesTable.referenceNumber} TEXT NOT NULL,
        ${JournalEntriesTable.description} TEXT,
        ${JournalEntriesTable.createdAt} TEXT NOT NULL,
        ${JournalEntriesTable.userId} INTEGER NOT NULL,
        ${JournalEntriesTable.currencyId} TEXT NOT NULL,
        ${JournalEntriesTable.amount} REAL NOT NULL DEFAULT 0.0,
        ${JournalEntriesTable.warehouseId} INTEGER,
        FOREIGN KEY (${JournalEntriesTable.userId}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalEntriesTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalEntriesTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 30. Journal Items
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${JournalItemsTable.tableName} (
        ${JournalItemsTable.itemId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${JournalItemsTable.entryId} INTEGER NOT NULL,
        ${JournalItemsTable.accountId} INTEGER NOT NULL,
        ${JournalItemsTable.amount} REAL NOT NULL DEFAULT 0.0,
        ${JournalItemsTable.lineDescription} TEXT,
        ${JournalItemsTable.currencyId} TEXT NOT NULL,
        ${JournalItemsTable.exPrice} REAL NOT NULL DEFAULT 1.0,
        ${JournalItemsTable.exPriceMain} REAL NOT NULL DEFAULT 1.0,
        ${JournalItemsTable.journalStatus} TEXT NOT NULL CHECK (${JournalItemsTable.journalStatus} IN ('increment', 'decrement')),
        FOREIGN KEY (${JournalItemsTable.entryId}) REFERENCES ${JournalEntriesTable.tableName} (${JournalEntriesTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${JournalItemsTable.accountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalItemsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 31. Cost Good Bills
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillsTable.tableName} (
        ${CostGoodBillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillsTable.createdAt} TEXT NOT NULL,
        ${CostGoodBillsTable.createdBy} INTEGER NOT NULL,
        ${CostGoodBillsTable.note} TEXT,
        ${CostGoodBillsTable.offerAmount} REAL NOT NULL,
        ${CostGoodBillsTable.currencyId} TEXT NOT NULL,
        ${CostGoodBillsTable.billNumber} INTEGER NOT NULL,
        ${CostGoodBillsTable.warehouseId} INTEGER NOT NULL,
        ${CostGoodBillsTable.journalEntryId} INTEGER,
        ${CostGoodBillsTable.personId} INTEGER NOT NULL,
        ${CostGoodBillsTable.billId} INTEGER NOT NULL,
        FOREIGN KEY (${CostGoodBillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CostGoodBillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${CostGoodBillsTable.billId}) REFERENCES ${BillsTable.tableName} (${BillsTable.id}) ON DELETE CASCADE
      )
    ''');

    // 32. Cost Good Bill Orders
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CostGoodBillOrdersTable.tableName} (
        ${CostGoodBillOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CostGoodBillOrdersTable.billId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable.categoryId} INTEGER NOT NULL,
        ${CostGoodBillOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${CostGoodBillOrdersTable.totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${CostGoodBillOrdersTable.billId}) REFERENCES ${CostGoodBillsTable.tableName} (${CostGoodBillsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${CostGoodBillOrdersTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 33. Categories Attributes
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CategoriesAttributesTable.tableName} (
        ${CategoriesAttributesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesAttributesTable.categoryId} INTEGER NOT NULL,
        ${CategoriesAttributesTable.subcategoryUnitId} INTEGER NOT NULL,
        FOREIGN KEY (${CategoriesAttributesTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${CategoriesAttributesTable.subcategoryUnitId}) REFERENCES ${SubcategoriesUnitsTable.tableName} (${SubcategoriesUnitsTable.id}) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // Triggers
  // ---------------------------------------------------------------------------
  static void _createTriggers(Database db) {
    JournalItemsBalanceTrigger.call(db);
    InventoryOrdersTrigger.call(db);

    // Drop the deprecated inventories triggers
    db.execute('DROP TRIGGER IF EXISTS inventories_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_delete_journal');
  }
}
