import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/main_category_repository.dart';

/// UseCases for MainCategoryRepository

class GetAllMainCategoriesUseCase {
  final MainCategoryRepository _repository;

  const GetAllMainCategoriesUseCase(this._repository);

  Future<Either<Failure, List<MainCategoryEntity>>> call({
    Iterable<int>? ids,
    bool getItems = false,
  }) async {
    return await _repository.get(ids: ids, getItems: getItems);
  }
}

class GetMainCategoryByIdUseCase {
  final MainCategoryRepository _repository;

  const GetMainCategoryByIdUseCase(this._repository);

  Future<Either<Failure, MainCategoryEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class AddMainCategoryUseCase {
  final MainCategoryRepository _repository;

  const AddMainCategoryUseCase(this._repository);

  Future<Either<Failure, MainCategoryEntity>> call(
    MainCategoryEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateMainCategoryUseCase {
  final MainCategoryRepository _repository;

  const UpdateMainCategoryUseCase(this._repository);

  Future<Either<Failure, MainCategoryEntity>> call(
    MainCategoryEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteMainCategoryUseCase {
  final MainCategoryRepository _repository;

  const DeleteMainCategoryUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class InitMainCategoryFormUseCase {
  final MainCategoryRepository _repository;
  const InitMainCategoryFormUseCase(this._repository);
  Future<Either<Failure, MainCategoryEntity?>> call(int? id) async {
    if (id == null) return const Right(null);
    return await _repository.getById(id);
  }
}

class SaveMainCategoryUseCase {
  final MainCategoryRepository _repository;
  const SaveMainCategoryUseCase(this._repository);
  Future<Either<Failure, int>> call(MainCategoryEntity entity) async {
    if (entity.id == 0) {
      final res = await _repository.insert(entity);
      return res.map((e) => e.id);
    } else {
      final res = await _repository.update(entity);
      return res.map((e) => e.id);
    }
  }
}
