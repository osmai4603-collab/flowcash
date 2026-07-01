import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول العملات.
class CurrenciesTable extends TableById {
  static final CurrenciesTable _instance = CurrenciesTable.internal();

  factory CurrenciesTable() => _instance;

  CurrenciesTable.internal();

  @override
  final String tableName = 'currencies';

  final String id = 'currency_id';
  final String currencyName = 'name';
  final String symbol = 'symbol';
  final String isDefault = 'is_default';

  @override
  List<String> get columns => [id, currencyName, symbol, isDefault];
}
