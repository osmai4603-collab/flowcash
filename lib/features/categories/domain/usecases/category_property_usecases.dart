import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/category_property_repository.dart';

/// UseCases for CategoryPropertyRepository

class GetCategoryPropertiesUseCase {
  final CategoryPropertyRepository _repository;

  const GetCategoryPropertiesUseCase(this._repository);

  Future<Either<Failure, List<CategoryPropertyEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetCategoryPropertiesByMainCategoryUseCase {
  final CategoryPropertyRepository _repository;

  const GetCategoryPropertiesByMainCategoryUseCase(this._repository);

  Future<Either<Failure, List<CategoryPropertyEntity>>> call(
    int mainCategoryId,
  ) async {
    return await _repository.whereMainCategoryId([mainCategoryId]);
  }
}

class GetCategoryPropertyByIdUseCase {
  final CategoryPropertyRepository _repository;

  const GetCategoryPropertyByIdUseCase(this._repository);

  Future<Either<Failure, CategoryPropertyEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class AddCategoryPropertyUseCase {
  final CategoryPropertyRepository _repository;

  const AddCategoryPropertyUseCase(this._repository);

  Future<Either<Failure, CategoryPropertyEntity>> call(
    CategoryPropertyEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateCategoryPropertyUseCase {
  final CategoryPropertyRepository _repository;

  const UpdateCategoryPropertyUseCase(this._repository);

  Future<Either<Failure, CategoryPropertyEntity>> call(
    CategoryPropertyEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteCategoryPropertyUseCase {
  final CategoryPropertyRepository _repository;

  const DeleteCategoryPropertyUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
