/// ثوابت جدول أسعار الصرف.
class ExchangePricesTable {
  const ExchangePricesTable._();

  static const String tableName = 'exchange_prices';

  static const String id = 'exchange_id';
  static const String fromCurrencyId = 'from_currency_id';
  static const String toCurrencyId = 'to_currency_id';
  static const String exchangePrice = 'exchange_price';

  static const List<String> fields = [
    id,
    fromCurrencyId,
    toCurrencyId,
    exchangePrice,
  ];
}
