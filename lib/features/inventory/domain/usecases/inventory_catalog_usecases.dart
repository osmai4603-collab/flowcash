import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_catalog_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_catalog_repository.dart';

/// UseCases for InventorySubcategoryRepository

class GetInventorySubcategoriesUseCase {
  final InventorySubcategoryRepository _repository;

  const GetInventorySubcategoriesUseCase(this._repository);

  Future<Either<Failure, List<InventorySubcategoryEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetInventorySubcategoryByIdUseCase {
  final InventorySubcategoryRepository _repository;

  const GetInventorySubcategoryByIdUseCase(this._repository);

  Future<Either<Failure, InventorySubcategoryEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertInventorySubcategoryUseCase {
  final InventorySubcategoryRepository _repository;

  const InsertInventorySubcategoryUseCase(this._repository);

  Future<Either<Failure, InventorySubcategoryEntity>> call(
    InventorySubcategoryEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateInventorySubcategoryUseCase {
  final InventorySubcategoryRepository _repository;

  const UpdateInventorySubcategoryUseCase(this._repository);

  Future<Either<Failure, InventorySubcategoryEntity>> call(
    InventorySubcategoryEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteInventorySubcategoryUseCase {
  final InventorySubcategoryRepository _repository;

  const DeleteInventorySubcategoryUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class FirstWhereStoreAndCategoryUseCase {
  final InventorySubcategoryRepository _repository;

  const FirstWhereStoreAndCategoryUseCase(this._repository);

  Future<Either<Failure, InventorySubcategoryEntity?>> call({
    required int categoryId,
    required int warehouseId,
  }) async {
    return await _repository.firstWhereStoreAndCategory(
      categoryId: categoryId,
      warehouseId: warehouseId,
    );
  }
}
