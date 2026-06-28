import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';

class SubAccountsTableSqlite extends SubAccountsTable implements SqliteTable {
  static final SubAccountsTableSqlite _instance = SubAccountsTableSqlite._internal();

  factory SubAccountsTableSqlite() => _instance;

  SubAccountsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${accountName} TEXT NOT NULL UNIQUE,
        ${accountNumber} TEXT NOT NULL UNIQUE,
        ${mainAccountId} INTEGER NOT NULL,
        ${currencyId} TEXT NOT NULL,
        ${incrementBalance} REAL NOT NULL DEFAULT 0.0,
        ${decrementBalance} REAL NOT NULL DEFAULT 0.0,
        ${balanceMax} REAL DEFAULT NULL,
        ${subAccountType} INTEGER NOT NULL,
        ${createdAt} TEXT NOT NULL,
        FOREIGN KEY (${mainAccountId}) REFERENCES ${MainAccountsTable().tableName} (${MainAccountsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
