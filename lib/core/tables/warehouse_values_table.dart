import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول القيم الافتراضية للمستودع.
class WarehouseValuesTable extends TableInfo {
  static final WarehouseValuesTable _instance = WarehouseValuesTable.internal();

  factory WarehouseValuesTable() => _instance;

  WarehouseValuesTable.internal();

  @override
  final String tableName = 'warehouse_default_values';

  final String id = 'value_id';
  final String warehouseId = 'warehouse_id';
  final String valueType = 'value_type';
  final String value = 'data';

  @override
  List<String> get columns => [id, warehouseId, valueType, value];
}
