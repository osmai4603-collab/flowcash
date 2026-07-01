import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';

class JournalItemsTableSqlite extends JournalItemsTable implements SqliteTable {
  static final JournalItemsTableSqlite _instance =
      JournalItemsTableSqlite._internal();

  factory JournalItemsTableSqlite() => _instance;

  JournalItemsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable =>
      '''
CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $entryId INTEGER NOT NULL,
        $accountId INTEGER NOT NULL,
        $amount REAL NOT NULL DEFAULT 0.0,
        $lineDescription TEXT,
        $currencyId TEXT NOT NULL,
        $exPrice REAL NOT NULL DEFAULT 1.0,
        $exPriceMain REAL NOT NULL DEFAULT 1.0,
        $journalStatus TEXT NOT NULL CHECK ($journalStatus IN ('increment', 'decrement')),
        FOREIGN KEY ($entryId) REFERENCES ${JournalEntriesTable().tableName} (${JournalEntriesTable().id}) ON DELETE CASCADE,
        FOREIGN KEY ($accountId) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY ($currencyId) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
