import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

abstract interface class OpeningQuantityDataSource
    implements AppDataSource<int, OpeningQuantityEntity, Map<String, dynamic>> {
  Future<OpeningQuantityEntity?> getOpeningQuantity({
    required int storeId,
    required int categoryId,
  });
  Future<double> getSumUnitsWhereStoreAndCategory(int storeId, int categoryId);
  Future<List<OpeningQuantityEntity>> whereCommodity(InventoryEntity commodity);
  Future<List<OpeningQuantityEntity>> whereStore(int storeId);
}
