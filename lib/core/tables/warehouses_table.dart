/// ثوابت جدول المستودعات.
class WarehousesTable {
  const WarehousesTable._();

  static const String tableName = 'warehouses';

  static const String id = 'id';
  static const String warehouseName = 'name';
  static const String location = 'location';
  static const String warehouseType = 'type';
  static const String parentId = 'parent_id';

  static const List<String> fields = [
    id,
    warehouseName,
    location,
    warehouseType,
    parentId,
  ];
}
