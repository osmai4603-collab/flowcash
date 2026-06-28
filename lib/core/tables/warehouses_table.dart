import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول المستودعات.
class WarehousesTable extends TableInfo {
  static final WarehousesTable _instance = WarehousesTable.internal();

  factory WarehousesTable() => _instance;

  WarehousesTable.internal();

  @override
  final String tableName = 'warehouses';

  final String id = 'id';
  final String warehouseName = 'name';
  final String location = 'location';
  final String warehouseType = 'type';
  final String parentId = 'parent_id';

  @override
  List<String> get columns => [id,
    warehouseName,
    location,
    warehouseType,
    parentId,];
}
