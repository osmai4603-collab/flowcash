import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/repositories/category_repository.dart';
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _dataSource;
  const CategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> get({Iterable<int>? ids}) async {
    try {
      final res = await _dataSource.get(ids: ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity?>> getById(int id) async {
    try {
      final res = await _dataSource.getById(id);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> insert(CategoryEntity entity) async {
    try {
      final insertedEntity = await _dataSource.insert(entity);
      return Right(insertedEntity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> update(CategoryEntity entity) async {
    try {
      final updatedEntity = await _dataSource.update(entity);
      return Right(updatedEntity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final deleted = await _dataSource.delete(id);
      return Right(deleted);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity?>> firstWhereCategoryName(String categoryName) async {
    try {
      final res = await _dataSource.firstWhereCategoryName(categoryName);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCategoryName(String categoryName) async {
    try {
      final res = await _dataSource.hasCategoryName(categoryName);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> whereNotInStore(int storeId) async {
    try {
      final res = await _dataSource.whereNotInStore(storeId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SimpleCategoryEntity>>> whereCategoryNameContains(String categoryName, {int? limit}) async {
    try {
      final res = await _dataSource.whereCategoryNameContains(categoryName, limit: limit);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getNewCategoryNumber() async {
    try {
      final res = await _dataSource.getNewCategoryNumber();
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
