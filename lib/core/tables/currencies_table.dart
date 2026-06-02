/// ثوابت جدول العملات.
class CurrenciesTable {
  const CurrenciesTable._();

  static const String tableName = 'currencies';

  static const String id = 'currency_id';
  static const String currencyName = 'name';
  static const String symbol = 'symbol';
  static const String fullSymbol = 'full_symbol';
  static const String country = 'country';
  static const String selected = 'is_selected';

  static const List<String> fields = [
    id,
    currencyName,
    symbol,
    fullSymbol,
    country,
    selected,
  ];
}
