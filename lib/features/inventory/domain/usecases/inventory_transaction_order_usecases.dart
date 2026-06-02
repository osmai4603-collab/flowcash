import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_transaction_order_repository.dart';

/// UseCases for InventoryTransactionOrderRepository

class GetInventoryTransactionOrdersUseCase {
  final InventoryTransactionOrderRepository _repository;

  const GetInventoryTransactionOrdersUseCase(this._repository);

  Future<Either<Failure, List<InventoryTransactionOrderEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetInventoryTransactionOrderByIdUseCase {
  final InventoryTransactionOrderRepository _repository;

  const GetInventoryTransactionOrderByIdUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionOrderEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertInventoryTransactionOrderUseCase {
  final InventoryTransactionOrderRepository _repository;

  const InsertInventoryTransactionOrderUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionOrderEntity>> call(
    InventoryTransactionOrderEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateInventoryTransactionOrderUseCase {
  final InventoryTransactionOrderRepository _repository;

  const UpdateInventoryTransactionOrderUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionOrderEntity>> call(
    InventoryTransactionOrderEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteInventoryTransactionOrderUseCase {
  final InventoryTransactionOrderRepository _repository;

  const DeleteInventoryTransactionOrderUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
