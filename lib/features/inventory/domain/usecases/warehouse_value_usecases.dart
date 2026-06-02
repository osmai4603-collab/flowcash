
import 'package:flowcash/core/enums/warehouse_value_type.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_value_repository.dart';

/// UseCases for WarehouseValueRepository

class GetWarehouseValuesUseCase {
  final WarehouseValueRepository _repository;

  const GetWarehouseValuesUseCase(this._repository);

  Future<Either<Failure, List<WarehouseValueEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetWarehouseValueByIdUseCase {
  final WarehouseValueRepository _repository;

  const GetWarehouseValueByIdUseCase(this._repository);

  Future<Either<Failure, WarehouseValueEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertWarehouseValueUseCase {
  final WarehouseValueRepository _repository;

  const InsertWarehouseValueUseCase(this._repository);

  Future<Either<Failure, WarehouseValueEntity>> call(
    WarehouseValueEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateWarehouseValueUseCase {
  final WarehouseValueRepository _repository;

  const UpdateWarehouseValueUseCase(this._repository);

  Future<Either<Failure, WarehouseValueEntity>> call(
    WarehouseValueEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteWarehouseValueUseCase {
  final WarehouseValueRepository _repository;

  const DeleteWarehouseValueUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class FetchValueUseCase {
  final WarehouseValueRepository _repository;

  const FetchValueUseCase(this._repository);

  Future<Either<Failure, WarehouseValueEntity?>> call({
    required int warehouseId,
    required WarehouseValueType valueType,
  }) async {
    return await _repository.fetchValue(
      warehouseId: warehouseId,
      valueType: valueType,
    );
  }
}

class FetchDefaultSalesAccountUseCase {
  final WarehouseValueRepository _repository;

  const FetchDefaultSalesAccountUseCase(this._repository);

  Future<Either<Failure, int>> call({required int warehouseId}) async {
    return await _repository.fetchDefaultSalesAccount(warehouseId: warehouseId);
  }
}

class FetchDefaultSalesReturnAccountUseCase {
  final WarehouseValueRepository _repository;

  const FetchDefaultSalesReturnAccountUseCase(this._repository);

  Future<Either<Failure, int>> call({required int warehouseId}) async {
    return await _repository.fetchDefaultSalesReturnAccount(
      warehouseId: warehouseId,
    );
  }
}

class FetchDefaultBuysAccountUseCase {
  final WarehouseValueRepository _repository;

  const FetchDefaultBuysAccountUseCase(this._repository);

  Future<Either<Failure, int>> call({required int warehouseId}) async {
    return await _repository.fetchDefaultBuysAccount(warehouseId: warehouseId);
  }
}

class FetchDefaultBuysReturnAccountUseCase {
  final WarehouseValueRepository _repository;

  const FetchDefaultBuysReturnAccountUseCase(this._repository);

  Future<Either<Failure, int>> call({required int warehouseId}) async {
    return await _repository.fetchDefaultBuysReturnAccount(
      warehouseId: warehouseId,
    );
  }
}

class UpdateValueUseCase {
  final WarehouseValueRepository _repository;

  const UpdateValueUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String? value,
    required int id,
  }) async {
    return await _repository.updateValue(value: value, id: id);
  }
}
