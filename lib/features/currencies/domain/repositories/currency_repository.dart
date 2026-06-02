import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

abstract interface class CurrencyRepository {
  Future<Either<Failure, List<CurrencyEntity>>> get({Iterable<String>? ids});
  Future<Either<Failure, CurrencyEntity?>> getById(String id);
  Future<Either<Failure, CurrencyEntity>> insert(CurrencyEntity entity);
  Future<Either<Failure, CurrencyEntity>> update(CurrencyEntity entity);
  Future<Either<Failure, bool>> delete(String id);
  Future<Either<Failure, List<CurrencyEntity>>> whereSelected();
  Future<Either<Failure, List<CurrencyEntity>>> whereNotSelected();
}
