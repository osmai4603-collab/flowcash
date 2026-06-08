import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class CategoryRepository
    implements RepositoryDB<CategoryEntity> {
  Future<Either<Failure, CategoryEntity?>> firstWhereCategoryName(
    String categoryName,
  );
  Future<Either<Failure, bool>> hasCategoryName(String categoryName);
  Future<Either<Failure, List<CategoryEntity>>> whereNotInStore(int storeId);
  Future<Either<Failure, List<SimpleCategoryEntity>>> whereCategoryNameContains(
    String categoryName, {
    int? limit,
  });
  Future<Either<Failure, String>> getNewCategoryNumber();
}
