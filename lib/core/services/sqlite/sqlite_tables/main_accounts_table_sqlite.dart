import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';

class MainAccountsTableSqlite extends MainAccountsTable implements SqliteTable {
  static final MainAccountsTableSqlite _instance = MainAccountsTableSqlite._internal();

  factory MainAccountsTableSqlite() => _instance;

  MainAccountsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${accountNumber} TEXT NOT NULL UNIQUE,
        ${accountName} TEXT NOT NULL UNIQUE,
        ${currencyId} TEXT NOT NULL,
        ${debitBalance} REAL NOT NULL DEFAULT 0.0,
        ${creditBalance} REAL NOT NULL DEFAULT 0.0,
        ${mainAccountType} INTEGER NOT NULL,
        ${numbersCounter} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
