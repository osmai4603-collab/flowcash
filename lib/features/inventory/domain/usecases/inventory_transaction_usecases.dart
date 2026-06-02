import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_transaction_repository.dart';

/// UseCases for InventoryTransactionRepository

class GetInventoryTransactionsUseCase {
  final InventoryTransactionRepository _repository;

  const GetInventoryTransactionsUseCase(this._repository);

  Future<Either<Failure, List<InventoryTransactionEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetInventoryTransactionByIdUseCase {
  final InventoryTransactionRepository _repository;

  const GetInventoryTransactionByIdUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertInventoryTransactionUseCase {
  final InventoryTransactionRepository _repository;

  const InsertInventoryTransactionUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionEntity>> call(
    InventoryTransactionEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateInventoryTransactionUseCase {
  final InventoryTransactionRepository _repository;

  const UpdateInventoryTransactionUseCase(this._repository);

  Future<Either<Failure, InventoryTransactionEntity>> call(
    InventoryTransactionEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteInventoryTransactionUseCase {
  final InventoryTransactionRepository _repository;

  const DeleteInventoryTransactionUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
