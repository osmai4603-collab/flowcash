/// ثوابت جدول القيم الافتراضية للمستودع.
class WarehouseValuesTable {
  const WarehouseValuesTable._();

  static const String tableName = 'warehouse_default_values';

  static const String id = 'value_id';
  static const String warehouseId = 'warehouse_id';
  static const String valueType = 'value_type';
  static const String value = 'data';

  static const List<String> fields = [
    id,
    warehouseId,
    valueType,
    value,
  ];
}
