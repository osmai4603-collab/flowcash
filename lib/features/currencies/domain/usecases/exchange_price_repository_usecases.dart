import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/repositories/exchange_price_repository.dart';

/// UseCases for ExchangePriceRepository

class GetExchangePricesUseCase {
  final ExchangePriceRepository _repository;

  const GetExchangePricesUseCase(this._repository);

  Future<Either<Failure, List<ExchangePriceEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetExchangePriceByIdUseCase {
  final ExchangePriceRepository _repository;

  const GetExchangePriceByIdUseCase(this._repository);

  Future<Either<Failure, ExchangePriceEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertExchangePriceUseCase {
  final ExchangePriceRepository _repository;

  const InsertExchangePriceUseCase(this._repository);

  Future<Either<Failure, ExchangePriceEntity>> call(
    ExchangePriceEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateExchangePriceUseCase {
  final ExchangePriceRepository _repository;

  const UpdateExchangePriceUseCase(this._repository);

  Future<Either<Failure, ExchangePriceEntity>> call(
    ExchangePriceEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteExchangePriceUseCase {
  final ExchangePriceRepository _repository;

  const DeleteExchangePriceUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetExPriceUseCase {
  final ExchangePriceRepository _repository;

  const GetExPriceUseCase(this._repository);

  Future<Either<Failure, double>> call(
    String fromCurrencyId,
    String toCurrencyId,
  ) async {
    return await _repository.getExPrice(fromCurrencyId, toCurrencyId);
  }
}
