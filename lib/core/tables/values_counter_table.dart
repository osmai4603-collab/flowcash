import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول عداد القيم.
class ValuesCounterTable extends TableById {
  static final ValuesCounterTable _instance = ValuesCounterTable.internal();

  factory ValuesCounterTable() => _instance;

  ValuesCounterTable.internal();

  @override
  final String tableName = 'values_counter';

  final String id = 'value_id';
  final String counterType = 'counter_type';
  final String count = 'count';
  final String counterMax = 'counter_max';
  final String incrementValue = 'increment_value';
  final String formatValue = 'format_value';

  @override
  List<String> get columns => [id,
    counterType,
    count,
    counterMax,
    incrementValue,
    formatValue,];
}
