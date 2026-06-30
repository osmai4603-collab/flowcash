import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class SubcategoryRepository
    implements RepositoryDB<SubcategoryEntity> {

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> get({
    Iterable<int>? ids,
    bool getItems = false,
  });

  @override
  Future<Either<Failure, SubcategoryEntity?>> getById(
    int id, {
    bool getItems = false,
  });

  Future<Either<Failure, List<SubcategoryEntity>>> whereMainCategoryId(
    Iterable<int> ids,
  );
  Future<Either<Failure, SubcategoryEntity?>> firstWhereCategory(
    int categoryId,
  );
  Future<Either<Failure, List<SubcategoryUnitEntity>>> getUnitsBySubcategoryIds(
    Iterable<int> ids,
  );
  Future<Either<Failure, SubcategoryEntity>> saveWithUnits(
    SubcategoryEntity entity,
    List<SubcategoryUnitEntity> units,
  );
  Future<Either<Failure, SubcategoryUnitEntity>> insertSubcategoryUnit(
    SubcategoryUnitEntity entity,
  );
  Future<Either<Failure, List<CategoryEntity>>> generateCategories(
    int subcategoryId,
  );

  Future<Either<Failure, bool>> deleteSubcategoryUnit(int id);
}
