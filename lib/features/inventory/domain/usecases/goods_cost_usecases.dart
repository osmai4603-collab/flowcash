import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/domain/repositories/goods_cost_repository.dart';

/// UseCases for GoodsCostRepository

class GetGoodsCostsUseCase {
  final GoodsCostRepository _repository;

  const GetGoodsCostsUseCase(this._repository);

  Future<Either<Failure, List<GoodsCostEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetGoodsCostByIdUseCase {
  final GoodsCostRepository _repository;

  const GetGoodsCostByIdUseCase(this._repository);

  Future<Either<Failure, GoodsCostEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertGoodsCostUseCase {
  final GoodsCostRepository _repository;

  const InsertGoodsCostUseCase(this._repository);

  Future<Either<Failure, GoodsCostEntity>> call(GoodsCostEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateGoodsCostUseCase {
  final GoodsCostRepository _repository;

  const UpdateGoodsCostUseCase(this._repository);

  Future<Either<Failure, GoodsCostEntity>> call(GoodsCostEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteGoodsCostUseCase {
  final GoodsCostRepository _repository;

  const DeleteGoodsCostUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
