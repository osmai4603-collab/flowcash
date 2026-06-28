import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول القيم الافتراضية.
class ValuesTable extends TableInfo {
  static final ValuesTable _instance = ValuesTable.internal();

  factory ValuesTable() => _instance;

  ValuesTable.internal();

  @override
  final String tableName = 'default_values';

  final String id = 'value_id';
  final String valueType = 'value_type';
  final String value = 'data';

  @override
  List<String> get columns => [id, value, valueType];
}
