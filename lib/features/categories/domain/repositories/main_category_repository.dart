import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class MainCategoryRepository
    implements RepositoryDB<MainCategoryEntity> {
  @override
  Future<Either<Failure, List<MainCategoryEntity>>> get({
    Iterable<int>? ids,
    bool getItems = false,
  });

  @override
  Future<Either<Failure, MainCategoryEntity?>> getById(
    int id, {
    bool getItems = false,
  });

  Future<Either<Failure, MainCategoryEntity?>> firstWhereCategoryName(
    String categoryName,
  );
}
