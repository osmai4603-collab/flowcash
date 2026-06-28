import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';

class AccountingPeriodsTableSqlite extends AccountingPeriodsTable
    implements SqliteTable {
  static final AccountingPeriodsTableSqlite _instance =
      AccountingPeriodsTableSqlite._internal();

  factory AccountingPeriodsTableSqlite() => _instance;

  AccountingPeriodsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable =>
      '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${balance} REAL NOT NULL DEFAULT 0.0,
        ${currencyId} TEXT NOT NULL,
        ${lastPeriodId} INTEGER,
        ${periodName} TEXT NOT NULL UNIQUE,
        ${dateOfStartPeriod} TEXT NOT NULL UNIQUE,
        ${dateOfEndPeriod} TEXT,
        ${inventoryType} TEXT,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${lastPeriodId}) REFERENCES ${tableName} (${id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
