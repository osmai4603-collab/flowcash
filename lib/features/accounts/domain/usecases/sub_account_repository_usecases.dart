import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';

/// UseCases for SubAccountRepository

class GetSubAccountsUseCase {
  final SubAccountRepository _repository;

  const GetSubAccountsUseCase(this._repository);

  Future<Either<Failure, List<SubAccountEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetSubAccountByIdUseCase {
  final SubAccountRepository _repository;

  const GetSubAccountByIdUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertSubAccountUseCase {
  final SubAccountRepository _repository;

  const InsertSubAccountUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity>> call(
    SubAccountEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateSubAccountUseCase {
  final SubAccountRepository _repository;

  const UpdateSubAccountUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity>> call(
    SubAccountEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteSubAccountUseCase {
  final SubAccountRepository _repository;

  const DeleteSubAccountUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetSubaccountBalanceUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountBalanceUseCase(this._repository);

  Future<Either<Failure, double>> call(int subAccountId) async {
    return await _repository.getBalance(subAccountId);
  }
}

class GetSubaccountCountHistoriesUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountCountHistoriesUseCase(this._repository);

  Future<Either<Failure, int>> call(int subAccountId) async {
    return await _repository.getCountHistories(subAccountId);
  }
}

class GetSubaccountCountCreditorHistoriesUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountCountCreditorHistoriesUseCase(this._repository);

  Future<Either<Failure, int>> call(int subAccountId) async {
    return await _repository.getCountCreditorHistories(subAccountId);
  }
}

class GetSubaccountsWhereAccountTypeUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountsWhereAccountTypeUseCase(this._repository);

  Future<Either<Failure, List<SubAccountEntity>>> call(Iterable<SubAccountType> types) async {
    return await _repository.whereAccountType(types);
  }
}

class GetSubaccountCountDebtorHistoriesUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountCountDebtorHistoriesUseCase(this._repository);

  Future<Either<Failure, int>> call(int subAccountId) async {
    return await _repository.getCountDebtorHistories(subAccountId);
  }
}

class GetSubaccountDebtorBalanceUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountDebtorBalanceUseCase(this._repository);

  Future<Either<Failure, double>> call(int subAccountId) async {
    return await _repository.getDebtorBalance(subAccountId);
  }
}

class GetSubaccountCreditorBalanceUseCase {
  final SubAccountRepository _repository;

  const GetSubaccountCreditorBalanceUseCase(this._repository);

  Future<Either<Failure, double>> call(int subAccountId) async {
    return await _repository.getCreditorBalance(subAccountId);
  }
}

class FirstWhereMainAccountUseCase {
  final SubAccountRepository _repository;

  const FirstWhereMainAccountUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity?>> call(int mainAccountId) async {
    return await _repository.firstWhereMainAccount(mainAccountId);
  }
}

class GetGoodsCostUseCase {
  final SubAccountRepository _repository;

  const GetGoodsCostUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity>> call({
    required int personId,
    required int periodId,
  }) async {
    return await _repository.getGoodsCost(
      personId: personId,
      periodId: periodId,
    );
  }
}

class UpdateSubaccountBalancesUseCase {
  final SubAccountRepository _repository;

  const UpdateSubaccountBalancesUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required double debitBalance,
    required double creditBalance,
    required int incrementsCountHistories,
    required int decrementsCountHistories,
    required int subaccountId,
  }) async {
    return await _repository.updateBalances(
      debitBalance: debitBalance,
      creditBalance: creditBalance,
      incrementsCountHistories: incrementsCountHistories,
      decrementsCountHistories: decrementsCountHistories,
      id: subaccountId,
    );
  }
}

class ChangeDefaultSubaccountUseCase {
  final SubAccountRepository _repository;

  const ChangeDefaultSubaccountUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required int id,
    required int mainAccountId,
  }) async {
    return await _repository.changeDefaultAccount(
      id: id,
      mainAccountId: mainAccountId,
    );
  }
}

class UpdateSubaccountBalanceUseCase {
  final SubAccountRepository _repository;

  const UpdateSubaccountBalanceUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required bool isIncrement,
    required double amount,
    required int id,
  }) async {
    return await _repository.updateBalance(
      isIncrement: isIncrement,
      amount: amount,
      id: id,
    );
  }
}

class FirstWhereMainAccountAndPersonUseCase {
  final SubAccountRepository _repository;

  const FirstWhereMainAccountAndPersonUseCase(this._repository);

  Future<Either<Failure, SubAccountEntity?>> call(
    int mainAccountId,
    int personId,
  ) async {
    return await _repository.firstWhereMainAccountAndPerson(
      mainAccountId,
      personId,
    );
  }
}

class GetSubaccountsByMainAccountUsecase {
  final SubAccountRepository _repository;

  const GetSubaccountsByMainAccountUsecase(this._repository);

  Future<Either<Failure, List<SubAccountEntity>>> call(
    Iterable<int> mainAccountIds,
  ) async {
    return await _repository.whereMainAccountId(mainAccountIds);
  }
}

class ResetSubAccountBalancesUseCase {
  final SubAccountRepository _repository;

  const ResetSubAccountBalancesUseCase(this._repository);

  Future<Either<Failure, double>> call(int subAccountId) async {
    return Right(0.0);
  }
}
