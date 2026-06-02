/// ثوابت جدول عداد القيم.
class ValuesCounterTable {
  const ValuesCounterTable._();

  static const String tableName = 'values_counter';

  static const String id = 'value_id';
  static const String counterType = 'counter_type';
  static const String count = 'count';
  static const String counterMax = 'counter_max';
  static const String incrementValue = 'increment_value';
  static const String formatValue = 'format_value';

  static const List<String> fields = [
    id,
    counterType,
    count,
    counterMax,
    incrementValue,
    formatValue,
  ];
}
