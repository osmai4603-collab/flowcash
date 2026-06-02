import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/category_repository.dart';

/// UseCases for CategoryRepository

class GetAllCategoriesUseCase {
  final CategoryRepository _repository;

  const GetAllCategoriesUseCase(this._repository);

  Future<Either<Failure, List<CategoryEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetCategoryByIdUseCase {
  final CategoryRepository _repository;

  const GetCategoryByIdUseCase(this._repository);

  Future<Either<Failure, CategoryEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class AddCategoryUseCase {
  final CategoryRepository _repository;

  const AddCategoryUseCase(this._repository);

  Future<Either<Failure, int>> call({required CategoryEntity category}) async {
    final result = await _repository.insert(category);
    return result.map((e) => e.id);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  const UpdateCategoryUseCase(this._repository);

  Future<Either<Failure, bool>> call({required CategoryEntity category}) async {
    final result = await _repository.update(category);
    return result.map((_) => true);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  const DeleteCategoryUseCase(this._repository);

  Future<Either<Failure, bool>> call({required int id}) async {
    return await _repository.delete(id);
  }
}

class FirstWhereCategoryNameUseCase {
  final CategoryRepository _repository;

  const FirstWhereCategoryNameUseCase(this._repository);

  Future<Either<Failure, CategoryEntity?>> call(String categoryName) async {
    return await _repository.firstWhereCategoryName(categoryName);
  }
}

class HasCategoryNameUseCase {
  final CategoryRepository _repository;

  const HasCategoryNameUseCase(this._repository);

  Future<Either<Failure, bool>> call(String categoryName) async {
    return await _repository.hasCategoryName(categoryName);
  }
}

class GetNewCategoryNumberUseCase {
  final CategoryRepository _repository;

  const GetNewCategoryNumberUseCase(this._repository);

  Future<Either<Failure, String>> call() async {
    return await _repository.getNewCategoryNumber();
  }
}

class CheckCategoryHasRequestsUseCase {
  Future<Either<Failure, bool>> call(int id) async {
    return const Right(false); // Placeholder
  }
}
