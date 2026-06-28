import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';

class ExchangePricesTableSqlite extends ExchangePricesTable implements SqliteTable {
  static final ExchangePricesTableSqlite _instance = ExchangePricesTableSqlite._internal();

  factory ExchangePricesTableSqlite() => _instance;

  ExchangePricesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${fromCurrencyId} TEXT NOT NULL,
        ${toCurrencyId} TEXT NOT NULL,
        ${exchangePrice} REAL NOT NULL,
        FOREIGN KEY (${fromCurrencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${toCurrencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON DELETE CASCADE
      )
  ''';
}
