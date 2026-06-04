import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/repositories/interfaces/value_counter_repository.dart';

/// UseCases for ValueCounterRepository

class GetValueCountersUseCase {
  final ValueCounterRepository _repository;

  const GetValueCountersUseCase(this._repository);

  Future<Either<Failure, List<ValueCounterEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetValueCounterByIdUseCase {
  final ValueCounterRepository _repository;

  const GetValueCounterByIdUseCase(this._repository);

  Future<Either<Failure, ValueCounterEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertValueCounterUseCase {
  final ValueCounterRepository _repository;

  const InsertValueCounterUseCase(this._repository);

  Future<Either<Failure, ValueCounterEntity>> call(
    ValueCounterEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateValueCounterUseCase {
  final ValueCounterRepository _repository;

  const UpdateValueCounterUseCase(this._repository);

  Future<Either<Failure, ValueCounterEntity>> call(
    ValueCounterEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteValueCounterUseCase {
  final ValueCounterRepository _repository;

  const DeleteValueCounterUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetNextCounterUseCase {
  final ValueCounterRepository _repository;

  const GetNextCounterUseCase(this._repository);

  Future<Either<Failure, int>> call(int valueGroupId) async {
    return await _repository.getNextCounter(valueGroupId);
  }
}

class GetNextCounterByGroupUseCase {
  final ValueCounterRepository _repository;

  const GetNextCounterByGroupUseCase(this._repository);

  Future<Either<Failure, int>> call(HistoriesGroup historyGroup) async {
    return await _repository.getNextCounterByGroup(historyGroup);
  }
}
