import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/entities/hint_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/repositories/interfaces/hint_repository.dart';

/// UseCases for HintRepository

class GetHintsUseCase {
  final HintRepository _repository;

  const GetHintsUseCase(this._repository);

  Future<Either<Failure, List<HintEntity>>> call({Iterable<int>? ids}) async {
    return await _repository.get(ids: ids);
  }
}

class GetHintByIdUseCase {
  final HintRepository _repository;

  const GetHintByIdUseCase(this._repository);

  Future<Either<Failure, HintEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertHintUseCase {
  final HintRepository _repository;

  const InsertHintUseCase(this._repository);

  Future<Either<Failure, HintEntity>> call(HintEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateHintUseCase {
  final HintRepository _repository;

  const UpdateHintUseCase(this._repository);

  Future<Either<Failure, HintEntity>> call(HintEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteHintUseCase {
  final HintRepository _repository;

  const DeleteHintUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class WhereHintTypeAndNameUseCase {
  final HintRepository _repository;

  const WhereHintTypeAndNameUseCase(this._repository);

  Future<Either<Failure, HintEntity?>> call(
    HistoriesGroup historyGroup,
    String hintName,
  ) async {
    return await _repository.whereHintTypeAndName(historyGroup, hintName);
  }
}

class GetHintTypeUseCase {
  final HintRepository _repository;

  const GetHintTypeUseCase(this._repository);

  Future<Either<Failure, HintEntity>> call(
    HistoriesGroup mainAccountId,
    String name,
  ) async {
    return await _repository.getHintType(mainAccountId, name);
  }
}

class GetHintTypeAndNameUseCase {
  final HintRepository _repository;

  const GetHintTypeAndNameUseCase(this._repository);

  Future<Either<Failure, HintEntity>> call(
    HistoriesGroup mainAccountId,
    String hintName,
  ) async {
    return await _repository.getHintTypeAndName(mainAccountId, hintName);
  }
}
