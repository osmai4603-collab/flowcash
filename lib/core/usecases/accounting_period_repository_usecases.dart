import 'package:flowcash/core/repositories/interfaces/accounting_period_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/entities/accounting_period_entity.dart';

/// UseCases for AccountingPeriodRepository

class GetAccountingPeriodsUseCase {
  final AccountingPeriodRepository _repository;

  const GetAccountingPeriodsUseCase(this._repository);

  Future<Either<Failure, List<AccountingPeriodEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetAccountingPeriodByIdUseCase {
  final AccountingPeriodRepository _repository;

  const GetAccountingPeriodByIdUseCase(this._repository);

  Future<Either<Failure, AccountingPeriodEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertAccountingPeriodUseCase {
  final AccountingPeriodRepository _repository;

  const InsertAccountingPeriodUseCase(this._repository);

  Future<Either<Failure, AccountingPeriodEntity>> call(
    AccountingPeriodEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateAccountingPeriodUseCase {
  final AccountingPeriodRepository _repository;

  const UpdateAccountingPeriodUseCase(this._repository);

  Future<Either<Failure, AccountingPeriodEntity>> call(
    AccountingPeriodEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteAccountingPeriodUseCase {
  final AccountingPeriodRepository _repository;

  const DeleteAccountingPeriodUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}


final class GetAccountingPeriodWhereIdOpenUseCase {
  final AccountingPeriodRepository _repository;

  const GetAccountingPeriodWhereIdOpenUseCase(this._repository);

  Future<Either<Failure, AccountingPeriodEntity?>> call() async {
    return await _repository.whereIdOpen();
  }
}
