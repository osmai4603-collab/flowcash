import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/opening_quantity_repository.dart';

/// UseCases for OpeningQuantityRepository

class GetOpeningQuantitysUseCase {
  final OpeningQuantityRepository _repository;

  const GetOpeningQuantitysUseCase(this._repository);

  Future<Either<Failure, List<OpeningQuantityEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetOpeningQuantityByIdUseCase {
  final OpeningQuantityRepository _repository;

  const GetOpeningQuantityByIdUseCase(this._repository);

  Future<Either<Failure, OpeningQuantityEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertOpeningQuantityUseCase {
  final OpeningQuantityRepository _repository;

  const InsertOpeningQuantityUseCase(this._repository);

  Future<Either<Failure, OpeningQuantityEntity>> call(
    OpeningQuantityEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateOpeningQuantityUseCase {
  final OpeningQuantityRepository _repository;

  const UpdateOpeningQuantityUseCase(this._repository);

  Future<Either<Failure, OpeningQuantityEntity>> call(
    OpeningQuantityEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteOpeningQuantityUseCase {
  final OpeningQuantityRepository _repository;

  const DeleteOpeningQuantityUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetOpeningQuantityUseCase {
  final OpeningQuantityRepository _repository;

  const GetOpeningQuantityUseCase(this._repository);

  Future<Either<Failure, OpeningQuantityEntity?>> call({
    required int inventoryId,
  }) async {
    return await _repository.getOpeningQuantity(inventoryId: inventoryId);
  }
}

class GetSumUnitsByInventoryUseCase {
  final OpeningQuantityRepository _repository;

  const GetSumUnitsByInventoryUseCase(this._repository);

  Future<Either<Failure, double>> call(int inventoryId) async {
    return await _repository.getSumUnitsByInventory(inventoryId);
  }
}
