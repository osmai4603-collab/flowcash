import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/repositories/unit_repository.dart';
import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

import '../../../../core/enums/unit_type_enum.dart';

class UnitRepositoryImpl implements UnitRepository {
  final UnitLocalDataSource _dataSource;
  const UnitRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<UnitEntity>>> get({Iterable<int>? ids}) async {
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
  Future<Either<Failure, UnitEntity?>> getById(int id) async {
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
  Future<Either<Failure, UnitEntity>> insert(UnitEntity entity) async {
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
  Future<Either<Failure, UnitEntity>> update(UnitEntity entity) async {
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
  Future<Either<Failure, List<UnitEntity>>> whereBasic() async {
    try {
      final result = await _dataSource.whereBasic();
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnitEntity?>> getFirstWhereArgs({
    double? length,
    double? width,
    double? thickness,
    int? propertyId,
    required UnitType unitType,
    String? unitName,
  }) async {
    try {
      final result = await _dataSource.getFirstWhereArgs(
        length: length,
        width: width,
        thickness: thickness,
        propertyId: propertyId ?? 0,
        unitType: unitType,
        unitName: unitName,
      );
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnitEntity>>> getByMainCategory(
    int mainCategoryId,
  ) async {
    try {
      final res = await _dataSource.getByMainCategory(mainCategoryId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnitEntity>>> getAvailableForSubcategoryProperty({
    required int subcategoryId,
    required int propertyId,
  }) async {
    try {
      final res = await _dataSource.getAvailableForSubcategoryProperty(
        subcategoryId: subcategoryId,
        propertyId: propertyId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnitEntity>>> getUnitsBySubcategoryAndPropertyIds({
    required int subcategoryId,
    required List<int> propertyIds,
  }) async {
    try {
      final res = await _dataSource.getUnitsBySubcategoryAndPropertyIds(
        subcategoryId: subcategoryId,
        propertyIds: propertyIds,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnitEntity>>> getUnitsBySubcategoryIds(
    List<int> subcategoryIds,
  ) async {
    try {
      final res = await _dataSource.getUnitsBySubcategoryIds(subcategoryIds);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
