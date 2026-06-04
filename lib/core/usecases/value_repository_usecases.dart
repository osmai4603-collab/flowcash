import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/repositories/interfaces/value_repository.dart';

/// UseCases for ValueRepository

class GetValuesUseCase {
  final ValueRepository _repository;

  const GetValuesUseCase(this._repository);

  Future<Either<Failure, List<ValueEntity>>> call({Iterable<int>? ids}) async {
    return await _repository.get(ids: ids);
  }
}

class GetValueByIdUseCase {
  final ValueRepository _repository;

  const GetValueByIdUseCase(this._repository);

  Future<Either<Failure, ValueEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertValueUseCase {
  final ValueRepository _repository;

  const InsertValueUseCase(this._repository);

  Future<Either<Failure, ValueEntity>> call(ValueEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateValueUseCase {
  final ValueRepository _repository;

  const UpdateValueUseCase(this._repository);

  Future<Either<Failure, ValueEntity>> call(ValueEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteValueUseCase {
  final ValueRepository _repository;

  const DeleteValueUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
