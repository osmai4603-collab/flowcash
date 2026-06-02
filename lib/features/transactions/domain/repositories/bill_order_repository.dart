import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class BillOrderRepository implements RepositoryDB<BillOrderEntity> {
  Future<Either<Failure, List<BillOrderEntity>>> whereBillId(Iterable<int> ids);
  Future<Either<Failure, double>> getSumUnitWhereOrder(int categoryId, int storeId);
  Future<Either<Failure, BillOrderEntity?>> firstWhereCategoryId(int categoryId);
  Future<Either<Failure, List<BillOrderEntity>>> whereBatchId(Iterable<int> ids);
  Future<Either<Failure, List<BillOrderEntity>>> whereInventory(int inventoryId);
}
