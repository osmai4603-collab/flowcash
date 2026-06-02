import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/core/enums/warehouse_value_type.dart';

abstract interface class WarehouseValueDataSource
    implements AppDataSource<int, WarehouseValueEntity, Map<String, dynamic>> {
  Future<WarehouseValueEntity?> fetchValue({
    required int warehouseId,
    required WarehouseValueType valueType,
  });
  Future<int> fetchDefaultSalesAccount({required int warehouseId});
  Future<int> fetchDefaultSalesReturnAccount({required int warehouseId});
  Future<int> fetchDefaultBuysAccount({required int warehouseId});
  Future<int> fetchDefaultBuysReturnAccount({required int warehouseId});
  Future<Map<WarehouseValueType, WarehouseValueEntity>> fetchAsMap();
  Future<bool> updateValue({required String? value, required int id});
}
