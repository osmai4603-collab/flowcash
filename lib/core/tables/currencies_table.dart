/// ثوابت جدول العملات.
class CurrenciesTable {
  const CurrenciesTable._();

  static const String tableName = 'currencies';

  static const String id = 'currency_id';
  static const String currencyName = 'name';
  static const String symbol = 'symbol';
  static const String isDefault = 'is_default';

  static const List<String> fields = [
    id,
    currencyName,
    symbol,
    isDefault,
  ];
}
