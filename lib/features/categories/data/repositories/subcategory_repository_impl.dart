import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/subcategory_repository.dart';
import 'package:flowcash/features/categories/data/datasources/subcategory_data_source.dart';

class SubcategoryRepositoryImpl implements SubcategoryRepository {
  final SubcategoryLocalDataSource _dataSource;
  const SubcategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> get({Iterable<int>? ids, bool getItems = false}) async {
    try {
      // `getItem` is available for callers; datasource currently ignores it.
      final res = await _dataSource.get(ids: ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity?>> getById(int id, {bool getItems = false}) async {
    try {
      // `getItem` is available for callers; datasource currently ignores it.
      final res = await _dataSource.getById(id);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity>> insert(SubcategoryEntity entity) async {
    try {
      await _dataSource.insert(entity);
      return Right(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity>> update(SubcategoryEntity entity) async {
    try {
      await _dataSource.update(entity);
      return Right(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return Right(true);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> whereMainCategoryId(Iterable<int> ids) async {
    try {
      final res = await _dataSource.whereMainCategoryId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryUnitEntity>>> getUnitsBySubcategoryIds(
      Iterable<int> ids) async {
    try {
      final units = await _dataSource.getUnitsBySubcategoryIds(ids);
      return Right(units);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity>> saveWithUnits(
    SubcategoryEntity entity,
    List<SubcategoryUnitEntity> units,
  ) async {
    try {
      final savedEntity = await _dataSource.saveWithUnits(entity, units);
      return Right(savedEntity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubcategoryEntity?>> firstWhereCategory(int categoryId) async {
    try {
      final res = await _dataSource.firstWhereCategory(categoryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
