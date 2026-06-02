import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_repository.dart';

/// UseCases for InventoryRepository

class GetInventorysUseCase {
  final InventoryRepository _repository;

  const GetInventorysUseCase(this._repository);

  Future<Either<Failure, List<InventoryEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetInventoryByIdUseCase {
  final InventoryRepository _repository;

  const GetInventoryByIdUseCase(this._repository);

  Future<Either<Failure, InventoryEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertInventoryUseCase {
  final InventoryRepository _repository;

  const InsertInventoryUseCase(this._repository);

  Future<Either<Failure, InventoryEntity>> call(InventoryEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateInventoryUseCase {
  final InventoryRepository _repository;

  const UpdateInventoryUseCase(this._repository);

  Future<Either<Failure, InventoryEntity>> call(InventoryEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteInventoryUseCase {
  final InventoryRepository _repository;

  const DeleteInventoryUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class FirstWhereCategoryUseCase {
  final InventoryRepository _repository;

  const FirstWhereCategoryUseCase(this._repository);

  Future<Either<Failure, InventoryEntity?>> call(
    int categoryId,
    int storeId,
  ) async {
    return await _repository.firstWhereCategory(categoryId, storeId);
  }
}

class FirstWhereCategoryAndStoreUseCase {
  final InventoryRepository _repository;

  const FirstWhereCategoryAndStoreUseCase(this._repository);

  Future<Either<Failure, InventoryEntity?>> call(
    int categoryId,
    int storeId,
  ) async {
    return await _repository.firstWhereCategoryAndStore(categoryId, storeId);
  }
}

class GetInventoryUseCase {
  final InventoryRepository _repository;

  const GetInventoryUseCase(this._repository);

  Future<Either<Failure, InventoryEntity>> call({
    required int categoryId,
    required int warehouseId,
  }) async {
    return await _repository.getInventory(
      categoryId: categoryId,
      warehouseId: warehouseId,
    );
  }
}
