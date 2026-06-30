import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

abstract interface class UnitRepository implements RepositoryDB<UnitEntity> {
  Future<Either<Failure, List<UnitEntity>>> whereBasic();
  Future<Either<Failure, UnitEntity?>> getFirstWhereArgs({
    double? length,
    double? width,
    double? thickness,
    int? propertyId,
    required UnitType unitType,
    String? unitName,
  });
  Future<Either<Failure, List<UnitEntity>>> getByMainCategory(
    int mainCategoryId,
  );
  Future<Either<Failure, List<UnitEntity>>> getAvailableForSubcategoryProperty({
    required int subcategoryId,
    required int propertyId,
  });
  Future<Either<Failure, List<UnitEntity>>> getUnitsBySubcategoryAndPropertyIds({
    required int subcategoryId,
    required List<int> propertyIds,
  });
  Future<Either<Failure, List<UnitEntity>>> getUnitsBySubcategoryIds(
    List<int> subcategoryIds,
  );
}
