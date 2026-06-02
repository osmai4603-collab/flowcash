import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/inventory_catalogs_table.dart';
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
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_batches_table.dart';
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
import 'package:flowcash/core/tables/goods_costs_table.dart';
import 'package:flowcash/core/tables/assets_transactions_table.dart';
import 'package:flowcash/core/tables/values_table.dart';

final class SqliteSchemaManager {
  const SqliteSchemaManager._();

  static const int latestVersion = 5;

  /// Create all tables as of the latest schema version.
  static void createAll(Database db) {
    _createV1Tables(db);
    _createV2Tables(db);
    _createV3Tables(db);
    _createV4Tables(db);
    _createV5Tables(db);
  }

  /// Apply incremental migrations from [fromVersion] (exclusive) up to [toVersion] (inclusive).
  /// Each migration is executed inside a transaction and is expected to be idempotent.
  static void migrate(Database db, int fromVersion, int toVersion) {
    if (fromVersion >= toVersion) return;
    for (var v = fromVersion + 1; v <= toVersion; v++) {
      db.execute('BEGIN');
      try {
        switch (v) {
          case 1:
            _createV1Tables(db);
            break;
          case 2:
            _createV2Tables(db);
            break;
          case 3:
            _createV3Tables(db);
            break;
          case 4:
            _createV4Tables(db);
            break;
          case 5:
            _createV5Tables(db);
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
  }

  // --- Schema pieces ---
  static void _createV1Tables(Database db) {
    // 1. Currencies
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CurrenciesTable.tableName} (
        ${CurrenciesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CurrenciesTable.currencyName} TEXT NOT NULL,
        ${CurrenciesTable.symbol} TEXT NOT NULL,
        ${CurrenciesTable.fullSymbol} TEXT NOT NULL,
        ${CurrenciesTable.country} TEXT NOT NULL,
        ${CurrenciesTable.selected} INTEGER NOT NULL DEFAULT 0
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
        ${WarehousesTable.warehouseName} TEXT NOT NULL,
        ${WarehousesTable.location} TEXT,
        ${WarehousesTable.warehouseType} INTEGER NOT NULL,
        ${WarehousesTable.parentId} INTEGER
      )
    ''');

    // 4. Persons
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
        FOREIGN KEY (${PersonsTable.receivableAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY (${PersonsTable.payableAccountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE SET NULL
      )
    ''');

    // 5. Main Accounts
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${MainAccountsTable.tableName} (
        ${MainAccountsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${MainAccountsTable.accountNumber} TEXT NOT NULL UNIQUE,
        ${MainAccountsTable.accountName} TEXT NOT NULL,
        ${MainAccountsTable.imagePath} TEXT,
        ${MainAccountsTable.currencyId} TEXT NOT NULL,
        ${MainAccountsTable.incrementsBalance} REAL NOT NULL DEFAULT 0.0,
        ${MainAccountsTable.decrementsBalance} REAL NOT NULL DEFAULT 0.0,
        ${MainAccountsTable.mainAccountType} INTEGER NOT NULL,
        ${MainAccountsTable.numbersCounter} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${MainAccountsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 6. Sub Accounts
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${SubAccountsTable.tableName} (
        ${SubAccountsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubAccountsTable.accountName} TEXT NOT NULL UNIQUE,
        ${SubAccountsTable.accountNumber} TEXT NOT NULL UNIQUE,
        ${SubAccountsTable.mainAccountId} INTEGER NOT NULL,
        ${SubAccountsTable.currencyId} TEXT NOT NULL,
        ${SubAccountsTable.incrementsBalance} REAL NOT NULL DEFAULT 0.0,
        ${SubAccountsTable.decrementsBalance} REAL NOT NULL DEFAULT 0.0,
        ${SubAccountsTable.balanceMax} REAL DEFAULT NULL,
        ${SubAccountsTable.subAccountType} INTEGER NOT NULL,
        ${SubAccountsTable.createdAt} TEXT NOT NULL,
        FOREIGN KEY (${SubAccountsTable.mainAccountId}) REFERENCES ${MainAccountsTable.tableName} (${MainAccountsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${SubAccountsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON DELETE RESTRICT
      )
    ''');
  }

  static void _createV2Tables(Database db) {
    // content moved from previous implementation
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

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${HintsTable.tableName} (
        ${HintsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${HintsTable.hintName} TEXT NOT NULL,
        ${HintsTable.hintType} TEXT NOT NULL,
        UNIQUE(${HintsTable.hintType}, ${HintsTable.hintName})
      )
    ''');

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
        FOREIGN KEY (${FinancialTransactionsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${FinancialBondsTable.hintId}) REFERENCES ${HintsTable.tableName} (${HintsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

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
  }

  static void _createV3Tables(Database db) {
    // 1. Categories
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
        FOREIGN KEY (${CategoriesTable.categoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.pricingUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable.inventoryUnitId}) REFERENCES ${UnitsTable.tableName} (${UnitsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 2. Subcategories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${SubcategoriesTable.tableName} (
        ${SubcategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubcategoriesTable.mainCategoryId} INTEGER,
        ${SubcategoriesTable.catalogName} TEXT NOT NULL,
        ${SubcategoriesTable.catalogNumber} TEXT,
        FOREIGN KEY (${SubcategoriesTable.mainCategoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE SET NULL
      )
    ''');

    // 3. Inventories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoriesTable.tableName} (
        ${InventoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoriesTable.categoryId} INTEGER NOT NULL,
        ${InventoriesTable.storeId} INTEGER NOT NULL,
        ${InventoriesTable.costType} TEXT NOT NULL,
        ${InventoriesTable.revenueAccountId} INTEGER,
        ${InventoriesTable.expenseAccountId} INTEGER,
        ${InventoriesTable.incomeStockId} INTEGER,
        ${InventoriesTable.outcomeStockId} INTEGER,
        ${InventoriesTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${InventoriesTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 4. Inventory Subcategories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventorySubcategoriesTable.tableName} (
        ${InventorySubcategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventorySubcategoriesTable.storeId} INTEGER NOT NULL,
        ${InventorySubcategoriesTable.catalogId} INTEGER NOT NULL,
        ${InventorySubcategoriesTable.revenueAccountId} INTEGER,
        ${InventorySubcategoriesTable.expenseAccountId} INTEGER,
        ${InventorySubcategoriesTable.incomeStockId} INTEGER,
        ${InventorySubcategoriesTable.outcomeStockId} INTEGER,
        FOREIGN KEY (${InventorySubcategoriesTable.catalogId}) REFERENCES ${SubcategoriesTable.tableName} (${SubcategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');

    // 5. Inventory Batches
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoryBatchesTable.tableName} (
        ${InventoryBatchesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryBatchesTable.batchNumber} TEXT NOT NULL,
        ${InventoryBatchesTable.inventoryId} INTEGER NOT NULL,
        ${InventoryBatchesTable.personId} INTEGER,
        ${InventoryBatchesTable.batchSource} TEXT NOT NULL,
        ${InventoryBatchesTable.batchStatus} TEXT NOT NULL,
        ${InventoryBatchesTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${InventoryBatchesTable.unitCost} REAL NOT NULL DEFAULT 0.0,
        ${InventoryBatchesTable.inputDate} TEXT NOT NULL,
        ${InventoryBatchesTable.productionDate} TEXT,
        ${InventoryBatchesTable.expirationDate} TEXT,
        FOREIGN KEY (${InventoryBatchesTable.inventoryId}) REFERENCES ${InventoriesTable.tableName} (${InventoriesTable.id}) ON DELETE CASCADE
      )
    ''');

    // 6. Inventory Transactions
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoryTransactionsTable.tableName} (
        ${InventoryTransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsTable.createAt} TEXT NOT NULL,
        ${InventoryTransactionsTable.createdBy} INTEGER NOT NULL,
        ${InventoryTransactionsTable.note} TEXT,
        ${InventoryTransactionsTable.warehouseId} INTEGER NOT NULL,
        ${InventoryTransactionsTable.personId} INTEGER,
        ${InventoryTransactionsTable.billNumber} INTEGER NOT NULL,
        ${InventoryTransactionsTable.transactionType} TEXT NOT NULL,
        FOREIGN KEY (${InventoryTransactionsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    // 7. Inventory Transactions Orders
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${InventoryTransactionsOrdersTable.tableName} (
        ${InventoryTransactionsOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${InventoryTransactionsOrdersTable.inventoryBatchId} INTEGER,
        ${InventoryTransactionsOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${InventoryTransactionsOrdersTable.tranId} INTEGER NOT NULL,
        ${InventoryTransactionsOrdersTable.transactionType} TEXT NOT NULL,
        FOREIGN KEY (${InventoryTransactionsOrdersTable.inventoryBatchId}) REFERENCES ${InventoryBatchesTable.tableName} (${InventoryBatchesTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${InventoryTransactionsOrdersTable.tranId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE CASCADE
      )
    ''');

    // 8. Opening Quantities
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${OpeningQuantitiesTable.tableName} (
        ${OpeningQuantitiesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${OpeningQuantitiesTable.categoryId} INTEGER NOT NULL,
        ${OpeningQuantitiesTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${OpeningQuantitiesTable.warehouseId} INTEGER NOT NULL,
        ${OpeningQuantitiesTable.createAt} TEXT NOT NULL,
        ${OpeningQuantitiesTable.costTotal} REAL NOT NULL DEFAULT 0.0,
        ${OpeningQuantitiesTable.periodId} INTEGER NOT NULL,
        FOREIGN KEY (${OpeningQuantitiesTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT
      )
    ''');
  }

  static void _createV4Tables(Database db) {
    // 1. Main Categories
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${MainCategoriesTable.tableName} (
        ${MainCategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${MainCategoriesTable.categoryName} TEXT NOT NULL,
        ${MainCategoriesTable.unitType} TEXT NOT NULL,
        ${MainCategoriesTable.categoryType} TEXT NOT NULL,
        ${MainCategoriesTable.unitName} TEXT NOT NULL
      )
    ''');

    // 2. Category Properties
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

    // 3. Units
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${UnitsTable.tableName} (
        ${UnitsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${UnitsTable.unitType} TEXT NOT NULL,
        ${UnitsTable.unitName} TEXT NOT NULL,
        ${UnitsTable.length} REAL NOT NULL DEFAULT 0.0,
        ${UnitsTable.width} REAL NOT NULL DEFAULT 0.0,
        ${UnitsTable.thickness} REAL NOT NULL DEFAULT 0.0
      )
    ''');

    // 4. Catalog Infos
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

    // 5. Program Users
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

    // 6. Bills
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${BillsTable.tableName} (
        ${BillsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillsTable.createAt} TEXT NOT NULL,
        ${BillsTable.createdBy} INTEGER NOT NULL,
        ${BillsTable.note} TEXT,
        ${BillsTable.offerAmount} REAL NOT NULL,
        ${BillsTable.currencyId} TEXT NOT NULL,
        ${BillsTable.billNumber} INTEGER NOT NULL,
        ${BillsTable.warehouseId} INTEGER NOT NULL,
        ${BillsTable.journalEntryId} INTEGER,
        ${BillsTable.personId} INTEGER,
        ${BillsTable.inventoryTransactionId} INTEGER,
        ${BillsTable.isCash} INTEGER NOT NULL DEFAULT 0,
        ${BillsTable.billType} TEXT NOT NULL,
        FOREIGN KEY (${BillsTable.createdBy}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${BillsTable.personId}) REFERENCES ${PersonsTable.tableName} (${PersonsTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillsTable.inventoryTransactionId}) REFERENCES ${InventoryTransactionsTable.tableName} (${InventoryTransactionsTable.id}) ON DELETE SET NULL
      )
    ''');

    // 7. Bill Orders
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${BillOrdersTable.tableName} (
        ${BillOrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${BillOrdersTable.billId} INTEGER NOT NULL,
        ${BillOrdersTable.categoryId} INTEGER NOT NULL,
        ${BillOrdersTable.countUnits} REAL NOT NULL DEFAULT 0.0,
        ${BillOrdersTable.totalPrice} REAL NOT NULL DEFAULT 0.0,
        ${BillOrdersTable.orderType} TEXT NOT NULL,
        ${BillOrdersTable.inventoryId} INTEGER,
        ${BillOrdersTable.batchId} INTEGER,
        FOREIGN KEY (${BillOrdersTable.billId}) REFERENCES ${BillsTable.tableName} (${BillsTable.id}) ON DELETE CASCADE,
        FOREIGN KEY (${BillOrdersTable.categoryId}) REFERENCES ${CategoriesTable.tableName} (${CategoriesTable.id}) ON DELETE RESTRICT,
        FOREIGN KEY (${BillOrdersTable.inventoryId}) REFERENCES ${InventoriesTable.tableName} (${InventoriesTable.id}) ON DELETE SET NULL,
        FOREIGN KEY (${BillOrdersTable.batchId}) REFERENCES ${InventoryBatchesTable.tableName} (${InventoryBatchesTable.id}) ON DELETE SET NULL
      )
    ''');

    // 9. Goods Costs
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${GoodsCostsTable.tableName} (
        ${GoodsCostsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${GoodsCostsTable.createAt} TEXT NOT NULL,
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

    // 10. Assets Transactions
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${AssetsTransactionsTable.tableName} (
        ${AssetsTransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${AssetsTransactionsTable.createAt} TEXT NOT NULL,
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

    // 12. Default Values
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${ValuesTable.tableName} (
        ${ValuesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${ValuesTable.valueType} TEXT NOT NULL,
        ${ValuesTable.value} TEXT NOT NULL
      )
    ''');
  }

  static void _createV5Tables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${JournalEntriesTable.tableName} (
        ${JournalEntriesTable.entryId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${JournalEntriesTable.referenceNumber} TEXT NOT NULL,
        ${JournalEntriesTable.description} TEXT,
        ${JournalEntriesTable.createdAt} TEXT NOT NULL,
        ${JournalEntriesTable.userId} INTEGER NOT NULL,
        ${JournalEntriesTable.currencyId} TEXT NOT NULL,
        ${JournalEntriesTable.exPrice} REAL NOT NULL DEFAULT 1.0,
        ${JournalEntriesTable.baseAmount} REAL NOT NULL DEFAULT 0.0,
        ${JournalEntriesTable.warehouseId} INTEGER,
        FOREIGN KEY (${JournalEntriesTable.userId}) REFERENCES ${ProgramUsersTable.tableName} (${ProgramUsersTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalEntriesTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalEntriesTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${JournalItemsTable.tableName} (
        ${JournalItemsTable.itemId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${JournalItemsTable.entryId} INTEGER NOT NULL,
        ${JournalItemsTable.accountId} INTEGER NOT NULL,
        ${JournalItemsTable.debit} REAL NOT NULL DEFAULT 0.0,
        ${JournalItemsTable.credit} REAL NOT NULL DEFAULT 0.0,
        ${JournalItemsTable.lineDescription} TEXT,
        ${JournalItemsTable.currencyId} TEXT NOT NULL,
        ${JournalItemsTable.debitBase} REAL NOT NULL DEFAULT 0.0,
        ${JournalItemsTable.creditBase} REAL NOT NULL DEFAULT 0.0,
        ${JournalItemsTable.warehouseId} INTEGER,
        FOREIGN KEY (${JournalItemsTable.entryId}) REFERENCES ${JournalEntriesTable.tableName} (${JournalEntriesTable.entryId}) ON DELETE CASCADE,
        FOREIGN KEY (${JournalItemsTable.accountId}) REFERENCES ${SubAccountsTable.tableName} (${SubAccountsTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalItemsTable.currencyId}) REFERENCES ${CurrenciesTable.tableName} (${CurrenciesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${JournalItemsTable.warehouseId}) REFERENCES ${WarehousesTable.tableName} (${WarehousesTable.id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');
  }
}
