import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class CategoryPropertyRepository implements RepositoryDB<CategoryPropertyEntity> {
  Future<Either<Failure, List<CategoryPropertyEntity>>> whereMainCategoryId(Iterable<int> ids);
}
