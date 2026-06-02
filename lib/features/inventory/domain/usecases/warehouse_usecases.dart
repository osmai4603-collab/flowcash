import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_repository.dart';

/// UseCases for WarehouseRepository

class GetWarehousesUseCase {
  final WarehouseRepository _repository;

  const GetWarehousesUseCase(this._repository);

  Future<Either<Failure, List<WarehouseEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetWarehouseByIdUseCase {
  final WarehouseRepository _repository;

  const GetWarehouseByIdUseCase(this._repository);

  Future<Either<Failure, WarehouseEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertWarehouseUseCase {
  final WarehouseRepository _repository;

  const InsertWarehouseUseCase(this._repository);

  Future<Either<Failure, WarehouseEntity>> call(WarehouseEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateWarehouseUseCase {
  final WarehouseRepository _repository;

  const UpdateWarehouseUseCase(this._repository);

  Future<Either<Failure, WarehouseEntity>> call(WarehouseEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteWarehouseUseCase {
  final WarehouseRepository _repository;

  const DeleteWarehouseUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetByCodeUseCase {
  final WarehouseRepository _repository;

  const GetByCodeUseCase(this._repository);

  Future<Either<Failure, WarehouseEntity?>> call(String code) async {
    return await _repository.getByCode(code);
  }
}
