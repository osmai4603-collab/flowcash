import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/features/categories/data/datasources/category_property_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/main_category_repository.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';

class MainCategoryRepositoryImpl implements MainCategoryRepository {
  final MainCategoryLocalDataSource _dataSource;
  final CategoryPropertyDataSource _propertyDataSource;
  final SqliteDatabase _db;

  const MainCategoryRepositoryImpl(
    this._dataSource,
    this._propertyDataSource,
    this._db,
  );

  @override
  Future<Either<Failure, List<MainCategoryEntity>>> get({
    Iterable<int>? ids,
    bool getItems = false,
  }) async {
    try {
      final categories = await _dataSource.get(ids: ids);
      if (categories.isEmpty || !getItems) {
        return Right(categories);
      }

      final categoryIds = categories.map((category) => category.id);
      final properties = await _propertyDataSource.whereMainCategoryId(
        categoryIds,
      );
      final Map<int, List<CategoryPropertyEntity>> propertiesByCategory = {};
      for (final property in properties) {
        propertiesByCategory
            .putIfAbsent(property.mainCategoryId, () => [])
            .add(property);
      }

      final categoriesWithProperties = categories
          .map(
            (category) => category.copyWith(
              properties: propertiesByCategory[category.id] ?? const [],
            ),
          )
          .toList();
      return Right(categoriesWithProperties);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MainCategoryEntity?>> getById(
    int id, {
    bool getItems = false,
  }) async {
    try {
      final category = await _dataSource.getById(id);
      if (category == null || !getItems) return Right(category);

      final properties = await _propertyDataSource.whereMainCategoryId([
        category.id,
      ]);
      return Right(category.copyWith(properties: properties));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MainCategoryEntity>> insert(
    MainCategoryEntity entity,
  ) async {
    try {
      final category = await _dataSource.insert(entity);
      return Right(category);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MainCategoryEntity>> update(
    MainCategoryEntity entity,
  ) async {
    try {
      final category = await _dataSource.update(entity);
      return Right(category);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final result = await _dataSource.delete(id);
      return const Right(true);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MainCategoryEntity?>> firstWhereCategoryName(
    String categoryName,
  ) async {
    try {
      final category = await _dataSource.firstWhereCategoryName(categoryName);
      if (category == null) return const Right(null);

      final properties = await _propertyDataSource.whereMainCategoryId([
        category.id,
      ]);
      return Right(category.copyWith(properties: properties));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
