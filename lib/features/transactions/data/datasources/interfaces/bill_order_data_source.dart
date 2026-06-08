import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

abstract interface class BillOrderDataSource
    implements AppDataSource<int, BillOrderEntity, Map<String, dynamic>> {
  Future<List<BillOrderEntity>> whereBillId(Iterable<int> ids);
  Future<double> getSumUnitWhereOrder(int categoryId, int storeId);
  Future<BillOrderEntity?> firstWhereCategoryId(int categoryId);
  Future<List<BillOrderEntity>> whereBatchId(Iterable<int> ids);
  Future<List<BillOrderEntity>> whereInventory(int inventoryId);
}
