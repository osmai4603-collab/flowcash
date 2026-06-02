import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/subcategory_repository.dart';

/// UseCases for SubcategoryRepository

class GetSubcategoriesByMainCategoryUseCase {
  final SubcategoryRepository _repository;

  const GetSubcategoriesByMainCategoryUseCase(this._repository);

  Future<Either<Failure, List<SubcategoryEntity>>> call(int mainCategoryId) async {
    return await _repository.whereMainCategoryId([mainCategoryId]);
  }
}

class GetSubcategoryByIdUseCase {
  final SubcategoryRepository _repository;

  const GetSubcategoryByIdUseCase(this._repository);

  Future<Either<Failure, SubcategoryEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertSubcategoryUseCase {
  final SubcategoryRepository _repository;

  const InsertSubcategoryUseCase(this._repository);

  Future<Either<Failure, SubcategoryEntity>> call(SubcategoryEntity entity) {
    return _repository.insert(entity);
  }
}

class UpdateSubcategoryUseCase {
  final SubcategoryRepository _repository;

  const UpdateSubcategoryUseCase({required SubcategoryRepository repository}) : _repository = repository;

  Future<Either<Failure, SubcategoryEntity>> call(SubcategoryEntity subcategory) {
    return _repository.update(subcategory);
  }
}

class DeleteSubcategoryUseCase {
  final SubcategoryRepository _repository;

  const DeleteSubcategoryUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetSubcategoryUnitsByMainCategoryUseCase {
  final SubcategoryRepository _repository;
  const GetSubcategoryUnitsByMainCategoryUseCase(this._repository);
  Future<Either<Failure, List<SubcategoryUnitEntity>>> call(List<int> ids) async {
      return await _repository.getUnitsBySubcategoryIds(ids);
  }
}

class GetSubcategoryUnitsBySubcategoryIdsUseCase {
  final SubcategoryRepository _repository;
  const GetSubcategoryUnitsBySubcategoryIdsUseCase(this._repository);
  Future<Either<Failure, List<SubcategoryUnitEntity>>> call(List<int> ids) async {
      return await _repository.getUnitsBySubcategoryIds(ids);
  }
}

class SaveSubcategoryWithUnitsUseCase {
  final SubcategoryRepository _repository;
  const SaveSubcategoryWithUnitsUseCase(this._repository);
  Future<Either<Failure, SubcategoryEntity>> call(
    SubcategoryEntity catalog,
    List<SubcategoryUnitEntity> units,
  ) async {
    return await _repository.saveWithUnits(catalog, units);
  }
}
