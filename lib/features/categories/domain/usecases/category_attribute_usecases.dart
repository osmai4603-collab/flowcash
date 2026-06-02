import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/category_attribute_repository.dart';

/// UseCases for CategoryAttributeRepository

class GetCategoryAttributesUseCase {
  final CategoryAttributeRepository _repository;

  const GetCategoryAttributesUseCase(this._repository);

  Future<Either<Failure, List<CategoryAttributeEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetCategoryAttributeByIdUseCase {
  final CategoryAttributeRepository _repository;

  const GetCategoryAttributeByIdUseCase(this._repository);

  Future<Either<Failure, CategoryAttributeEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class AddCategoryAttributeUseCase {
  final CategoryAttributeRepository _repository;

  const AddCategoryAttributeUseCase(this._repository);

  Future<Either<Failure, CategoryAttributeEntity>> call(
    CategoryAttributeEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateCategoryAttributeUseCase {
  final CategoryAttributeRepository _repository;

  const UpdateCategoryAttributeUseCase(this._repository);

  Future<Either<Failure, CategoryAttributeEntity>> call(
    CategoryAttributeEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteCategoryAttributeUseCase {
  final CategoryAttributeRepository _repository;

  const DeleteCategoryAttributeUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
