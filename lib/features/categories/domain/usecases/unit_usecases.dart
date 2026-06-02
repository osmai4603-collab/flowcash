import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/unit_repository.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

/// UseCases for UnitRepository

class GetUnitsUseCase {
  final UnitRepository _repository;

  const GetUnitsUseCase(this._repository);

  Future<Either<Failure, List<UnitEntity>>> call({Iterable<int>? ids}) async {
    return await _repository.get(ids: ids);
  }
}

class GetUnitByIdUseCase {
  final UnitRepository _repository;

  const GetUnitByIdUseCase(this._repository);

  Future<Either<Failure, UnitEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertUnitUseCase {
  final UnitRepository _repository;

  const InsertUnitUseCase(this._repository);

  Future<Either<Failure, UnitEntity>> call(UnitEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateUnitUseCase {
  final UnitRepository _repository;

  const UpdateUnitUseCase(this._repository);

  Future<Either<Failure, UnitEntity>> call(UnitEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteUnitUseCase {
  final UnitRepository _repository;

  const DeleteUnitUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetUnitsByUnitTypes {
  final UnitRepository _repository;
  const GetUnitsByUnitTypes(this._repository);
  Future<Either<Failure, List<UnitEntity>>> call(Iterable<UnitType> types) async {
    final result = await _repository.get();
    return result.map((list) => list.where((unit) => types.contains(unit.unitType)).toList());
  }
}

class GetUnitsForPropertyUseCase {
  final UnitRepository _repository;
  const GetUnitsForPropertyUseCase(this._repository);
  Future<Either<Failure, List<UnitEntity>>> call(int propertyId) async {
    // This depends on Repository support for wherePropertyId
    // For now, filtering from all units if not explicitly supported
    final result = await _repository.get();
    return result.map((list) => list.where((unit) => unit.propertyId == propertyId).toList());
  }
}

class SaveUnitSelectionUseCase {
  final UnitRepository _repository;
  const SaveUnitSelectionUseCase(this._repository);
  Future<Either<Failure, bool>> call(UnitEntity unit) async {
    if (unit.id == 0) {
      final res = await _repository.insert(unit);
      return res.map((_) => true);
    } else {
      final res = await _repository.update(unit);
      return res.map((_) => true);
    }
  }
}

class GetAvailableUnitsForPropertyUseCase {
    final UnitRepository _repository;
    const GetAvailableUnitsForPropertyUseCase(this._repository);
    Future<Either<Failure, List<UnitEntity>>> call(int propertyId) async {
        return await GetUnitsForPropertyUseCase(_repository)(propertyId);
    }
}
