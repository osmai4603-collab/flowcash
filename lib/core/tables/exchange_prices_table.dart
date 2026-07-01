import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول أسعار الصرف.
class ExchangePricesTable extends TableById {
  static final ExchangePricesTable _instance = ExchangePricesTable.internal();

  factory ExchangePricesTable() => _instance;

  ExchangePricesTable.internal();

  @override
  final String tableName = 'exchange_prices';

  final String id = 'exchange_id';
  final String fromCurrencyId = 'from_currency_id';
  final String toCurrencyId = 'to_currency_id';
  final String exchangePrice = 'exchange_price';

  @override
  List<String> get columns => [id,
    fromCurrencyId,
    toCurrencyId,
    exchangePrice,];
}
