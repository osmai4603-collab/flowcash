import 'package:flowcash/features/categories/data/datasources/category_attribute_data_source.dart';
import 'package:flowcash/features/categories/domain/repositories/category_attribute_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';

class CategoryAttributeRepositoryImpl implements CategoryAttributeRepository {
  final CategoryAttributeDataSource _dataSource;

  const CategoryAttributeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CategoryAttributeEntity>>> get({
    Iterable<int>? ids,
  }) async {
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
  Future<Either<Failure, CategoryAttributeEntity?>> getById(int id) async {
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
  Future<Either<Failure, CategoryAttributeEntity>> insert(
    CategoryAttributeEntity entity,
  ) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return Right(entityInserted);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryAttributeEntity>> update(
    CategoryAttributeEntity entity,
  ) async {
    try {
      final entityUpdated = await _dataSource.update(entity);
      return Right(entityUpdated);
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
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryAttributeEntity>>> whereCategoryId(
    Iterable<int> ids,
  ) async {
    try {
      final res = await _dataSource.whereCategoryId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryAttributeEntity>>> whereSubcategoryUnitId(
    Iterable<int> ids,
  ) async {
    try {
      final res = await _dataSource.whereSubcategoryUnitId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
