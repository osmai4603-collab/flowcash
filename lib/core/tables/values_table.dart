/// ثوابت جدول القيم الافتراضية.
class ValuesTable {
  const ValuesTable._();

  static const String tableName = 'default_values';

  static const String id = 'value_id';
  static const String valueType = 'value_type';
  static const String value = 'data';

  static const List<String> fields = [
    id,
    value,
    valueType,
  ];
}
