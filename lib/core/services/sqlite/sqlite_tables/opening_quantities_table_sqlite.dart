import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';

class OpeningQuantitiesTableSqlite extends OpeningQuantitiesTable implements SqliteTable {
  static final OpeningQuantitiesTableSqlite _instance = OpeningQuantitiesTableSqlite._internal();

  factory OpeningQuantitiesTableSqlite() => _instance;

  OpeningQuantitiesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${inventoryId} INTEGER NOT NULL,
        ${countUnits} REAL NOT NULL DEFAULT 0.0,
        ${createdAt} TEXT NOT NULL,
        ${costTotal} REAL NOT NULL DEFAULT 0.0,
        ${periodId} INTEGER NOT NULL,
        ${currencyId} TEXT NOT NULL,
        ${journalEntryId} INTEGER,
        FOREIGN KEY (${inventoryId}) REFERENCES ${InventoriesTable().tableName} (${InventoriesTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${periodId}) REFERENCES ${AccountingPeriodsTable().tableName} (${AccountingPeriodsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${journalEntryId}) REFERENCES ${JournalEntriesTable().tableName} (${JournalEntriesTable().id}) ON DELETE SET NULL,
        UNIQUE (${inventoryId}, ${periodId})
      )
  ''';
}
