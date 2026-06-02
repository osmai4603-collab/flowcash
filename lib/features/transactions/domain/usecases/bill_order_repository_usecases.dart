import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_order_repository.dart';

/// UseCases for BillOrderRepository

class GetBillOrdersUseCase {
  final BillOrderRepository _repository;

  const GetBillOrdersUseCase(this._repository);

  Future<Either<Failure, List<BillOrderEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetBillOrderByIdUseCase {
  final BillOrderRepository _repository;

  const GetBillOrderByIdUseCase(this._repository);

  Future<Either<Failure, BillOrderEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertBillOrderUseCase {
  final BillOrderRepository _repository;

  const InsertBillOrderUseCase(this._repository);

  Future<Either<Failure, BillOrderEntity>> call(BillOrderEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateBillOrderUseCase {
  final BillOrderRepository _repository;

  const UpdateBillOrderUseCase(this._repository);

  Future<Either<Failure, BillOrderEntity>> call(BillOrderEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteBillOrderUseCase {
  final BillOrderRepository _repository;

  const DeleteBillOrderUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetSumUnitWhereOrderUseCase {
  final BillOrderRepository _repository;

  const GetSumUnitWhereOrderUseCase(this._repository);

  Future<Either<Failure, double>> call(int categoryId, int storeId) async {
    return await _repository.getSumUnitWhereOrder(categoryId, storeId);
  }
}

class FirstWhereCategoryIdUseCase {
  final BillOrderRepository _repository;

  const FirstWhereCategoryIdUseCase(this._repository);

  Future<Either<Failure, BillOrderEntity?>> call(int categoryId) async {
    return await _repository.firstWhereCategoryId(categoryId);
  }
}
