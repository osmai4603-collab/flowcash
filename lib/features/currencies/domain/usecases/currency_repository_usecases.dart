import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/repositories/currency_repository.dart';

/// UseCases for CurrencyRepository

class GetCurrenciesUseCase {
  final CurrencyRepository _repository;

  const GetCurrenciesUseCase(this._repository);

  Future<Either<Failure, List<CurrencyEntity>>> call({
    Iterable<String>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetCurrencyByIdUseCase {
  final CurrencyRepository _repository;

  const GetCurrencyByIdUseCase(this._repository);

  Future<Either<Failure, CurrencyEntity?>> call(String id) async {
    return await _repository.getById(id);
  }
}

class InsertCurrencyUseCase {
  final CurrencyRepository _repository;

  const InsertCurrencyUseCase(this._repository);

  Future<Either<Failure, CurrencyEntity>> call(CurrencyEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateCurrencyUseCase {
  final CurrencyRepository _repository;

  const UpdateCurrencyUseCase(this._repository);

  Future<Either<Failure, CurrencyEntity>> call(CurrencyEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteCurrencyUseCase {
  final CurrencyRepository _repository;

  const DeleteCurrencyUseCase(this._repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await _repository.delete(id);
  }
}
