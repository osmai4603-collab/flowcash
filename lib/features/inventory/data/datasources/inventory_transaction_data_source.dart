import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';

abstract interface class InventoryTransactionDataSource
    implements
        AppDataSource<int, InventoryTransactionEntity, Map<String, dynamic>> {
  Future<List<InventoryTransactionEntity>> whereStoreId(Iterable<int> ids);
  Future<Map<int, InventoryTransactionEntity>> whereStoreToMap(int storeId);
  Future<List<InventoryTransactionEntity>> wherePersonId(Iterable<int> ids);
  Future<List<InventoryTransactionEntity>> whereStoreIdAndPersonId({
    required Iterable<int> storesIds,
    required Iterable<int> personsIds,
    bool trigger = false,
  });
  Future<List<int>> getIdsWhereStore(int storeId);
}
