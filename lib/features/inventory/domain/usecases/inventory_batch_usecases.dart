import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_batch_repository.dart';

/// UseCases for InventoryBatchRepository

class GetInventoryBatchsUseCase {
  final InventoryBatchRepository _repository;

  const GetInventoryBatchsUseCase(this._repository);

  Future<Either<Failure, List<InventoryBatchEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetInventoryBatchByIdUseCase {
  final InventoryBatchRepository _repository;

  const GetInventoryBatchByIdUseCase(this._repository);

  Future<Either<Failure, InventoryBatchEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertInventoryBatchUseCase {
  final InventoryBatchRepository _repository;

  const InsertInventoryBatchUseCase(this._repository);

  Future<Either<Failure, InventoryBatchEntity>> call(
    InventoryBatchEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateInventoryBatchUseCase {
  final InventoryBatchRepository _repository;

  const UpdateInventoryBatchUseCase(this._repository);

  Future<Either<Failure, InventoryBatchEntity>> call(
    InventoryBatchEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteInventoryBatchUseCase {
  final InventoryBatchRepository _repository;

  const DeleteInventoryBatchUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetUnitCostUseCase {
  final InventoryBatchRepository _repository;

  const GetUnitCostUseCase(this._repository);

  Future<Either<Failure, double>> call({
    required int inventoryId,
    required InventoryCostType unitCostType,
  }) async {
    return await _repository.getUnitCost(
      inventoryId: inventoryId,
      unitCostType: unitCostType,
    );
  }
}

class GetBatchUseCase {
  final InventoryBatchRepository _repository;

  const GetBatchUseCase(this._repository);

  Future<Either<Failure, InventoryBatchEntity?>> call({
    required int inventoryId,
    required InventoryCostType unitCostType,
  }) async {
    return await _repository.getBatch(
      inventoryId: inventoryId,
      unitCostType: unitCostType,
    );
  }
}
