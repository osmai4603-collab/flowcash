import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/features/accounts/domain/repositories/main_account_repository.dart';

/// UseCases for MainAccountRepository

class GetMainAccountsUseCase {
  final MainAccountRepository _repository;

  const GetMainAccountsUseCase(this._repository);

  Future<Either<Failure, List<MainAccountEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetMainAccountByIdUseCase {
  final MainAccountRepository _repository;

  const GetMainAccountByIdUseCase(this._repository);

  Future<Either<Failure, MainAccountEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertMainAccountUseCase {
  final MainAccountRepository _repository;

  const InsertMainAccountUseCase(this._repository);

  Future<Either<Failure, MainAccountEntity>> call(
    MainAccountEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateMainAccountUseCase {
  final MainAccountRepository _repository;

  const UpdateMainAccountUseCase(this._repository);

  Future<Either<Failure, MainAccountEntity>> call(
    MainAccountEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteMainAccountUseCase {
  final MainAccountRepository _repository;

  const DeleteMainAccountUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetMaxAccountNumberUseCase {
  final MainAccountRepository _repository;

  const GetMaxAccountNumberUseCase(this._repository);

  Future<Either<Failure, int?>> call(MainAccountGroup accountType) async {
    return await _repository.getMaxAccountNumber(accountType);
  }
}

class UpdateCounterUseCase {
  final MainAccountRepository _repository;

  const UpdateCounterUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required int counter,
    required int id,
  }) async {
    return await _repository.updateCounter(counter: counter, id: id);
  }
}

class UpdateMainAccountBalancesUseCase {
  final MainAccountRepository _repository;

  const UpdateMainAccountBalancesUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required double incrementBalance,
    required double decrementBalance,
    required int id,
  }) async {
    return await _repository.updateBalances(
      incrementBalance: incrementBalance,
      decrementBalance: decrementBalance,
      id: id,
    );
  }
}

class UpdateMainAccountBalanceUseCase {
  final MainAccountRepository _repository;

  const UpdateMainAccountBalanceUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required bool isIncrement,
    required double amount,
    required int subAccountId,
  }) async {
    return await _repository.updateBalance(
      isIncrement: isIncrement,
      amount: amount,
      subAccountId: subAccountId,
    );
  }
}

class FirstWhereSubAccountIdUseCase {
  final MainAccountRepository _repository;

  const FirstWhereSubAccountIdUseCase(this._repository);

  Future<Either<Failure, MainAccountEntity>> call(int subAccountId) async {
    return await _repository.firstWhereSubAccountId(subAccountId);
  }
}

class ResetMainAccountBalanceUseCase {
  final MainAccountRepository _repository;

  const ResetMainAccountBalanceUseCase(this._repository);

  Future<Either<Failure, double>> call(int mainAccountId) async {
    return Right(0.0);
  }
}
