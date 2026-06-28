import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';

class CurrenciesTableSqlite extends CurrenciesTable implements SqliteTable {
  static final CurrenciesTableSqlite _instance = CurrenciesTableSqlite._internal();

  factory CurrenciesTableSqlite() => _instance;

  CurrenciesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} TEXT PRIMARY KEY,
        ${currencyName} TEXT NOT NULL,
        ${symbol} TEXT NOT NULL,
        ${isDefault} INTEGER NOT NULL DEFAULT 0
      )
  ''';
}
