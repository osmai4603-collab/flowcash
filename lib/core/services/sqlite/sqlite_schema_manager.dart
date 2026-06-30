import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_triggers/journal_items_balance_trigger.dart';
import 'package:flowcash/core/services/sqlite/sqlite_triggers/inventory_balance_trigger.dart';
import 'package:flowcash/core/services/sqlite/sqlite_triggers/cost_good_balance_trigger.dart';
import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_tables.dart';

final class SqliteSchemaManager {
  const SqliteSchemaManager._();

  static const int currentVersion = 13;

  /// Create the full schema for a new database.
  static void createAll(Database db) {
    _createAllTables(db);
    createTriggers(db);
  }

  /// Apply incremental migrations from [fromVersion] (exclusive) up to [toVersion] (inclusive).
  static void migrate(Database db, int fromVersion, int toVersion) {
    if (fromVersion >= toVersion) return;
    db.execute('PRAGMA foreign_keys = OFF');
    try {
      for (var v = fromVersion + 1; v <= toVersion; v++) {
        db.execute('BEGIN');
        try {
          final migration = sqliteMigrations.firstWhere(
            (m) => m.version == v,
            orElse: () =>
                throw StateError('No migration defined for version $v'),
          );
          migration.execute(db);
          db.execute('COMMIT');
          debugPrint('Migration to version $v applied');
        } catch (e) {
          db.execute('ROLLBACK');
          debugPrint('Migration to version $v failed: $e');
          rethrow;
        }
      }
      // Recreate all triggers to ensure they are up-to-date with the latest code
      createTriggers(db);
    } finally {
      db.execute('PRAGMA foreign_keys = ON');
    }
  }

  // ---------------------------------------------------------------------------
  // Schema creation – all tables with their final structure
  // ---------------------------------------------------------------------------
  static void _createAllTables(Database db) {
    final tables = <SqliteTable>[
      CurrenciesTableSqlite(),
      ExchangePricesTableSqlite(),
      WarehousesTableSqlite(),
      MainAccountsTableSqlite(),
      SubAccountsTableSqlite(),
      PersonsTableSqlite(),
      AccountingPeriodsTableSqlite(),
      HintsTableSqlite(),
      ValuesCounterTableSqlite(),
      ProgramUsersTableSqlite(),
      FinancialBondsTableSqlite(),
      FinancialTransactionsTableSqlite(),
      CategoriesTableSqlite(),
      SubcategoriesTableSqlite(),
      InventoriesTableSqlite(),
      InventoryTransactionsTableSqlite(),
      InventoryTransactionsOrdersTableSqlite(),
      OpeningQuantitiesTableSqlite(),
      MainCategoriesTableSqlite(),
      CategoryPropertiesTableSqlite(),
      UnitsTableSqlite(),
      SubcategoriesUnitsTableSqlite(),
      BillsTableSqlite(),
      BillOrdersTableSqlite(),
      AssetsTransactionsTableSqlite(),
      WarehouseValuesTableSqlite(),
      ValuesTableSqlite(),
      JournalEntriesTableSqlite(),
      JournalItemsTableSqlite(),
      CostGoodBillsTableSqlite(),
      CostGoodBillOrdersTableSqlite(),
      CategoriesAttributesTableSqlite(),
    ];

    for (final table in tables) {
      db.execute(table.queryCreateTable);
    }
  }

  // ---------------------------------------------------------------------------
  // Triggers
  // ---------------------------------------------------------------------------
  static void createTriggers(Database db) {
    JournalItemsBalanceTrigger.call(db);
    InventoryBalanceTrigger.call(db);
    CostGoodBalanceTrigger.call(db);

    // Drop the deprecated inventories triggers
    db.execute('DROP TRIGGER IF EXISTS inventories_after_insert_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_update_journal');
    db.execute('DROP TRIGGER IF EXISTS inventories_after_delete_journal');
  }
}
