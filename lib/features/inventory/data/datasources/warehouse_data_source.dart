import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

abstract interface class WarehouseDataSource
    implements AppDataSource<int, WarehouseEntity, Map<String, dynamic>> {
  Future<List<WarehouseEntity>> getAllStoresWhereWarehouse(int warehouseId);
  Future<WarehouseEntity?> getByCode(String code);
}
