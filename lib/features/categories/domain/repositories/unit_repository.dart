import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:fpdart/src/either.dart';

abstract interface class UnitRepository implements RepositoryDB<UnitEntity> {
  Future<Either<Failure, List<UnitEntity>>> whereBasic();
}
