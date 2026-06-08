import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class ExchangePriceRepository
    implements RepositoryDB<ExchangePriceEntity> {
  Future<Either<Failure, double>> getExPrice(
    String fromCurrencyId,
    String toCurrencyId,
  );
  Future<Either<Failure, List<ExchangePriceEntity>>> getWhereFromCurrencyId(
    Iterable<String> ids,
  );
}
