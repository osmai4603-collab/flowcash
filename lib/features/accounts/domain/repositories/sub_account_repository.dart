import 'package:flowcash/core/entities/data_record.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class SubAccountRepository
    implements RepositoryDB<SubAccountEntity> {
  Future<Either<Failure, List<SubAccountEntity>>> whereMainAccount(
    int mainAccountId,
  );
  Future<Either<Failure, List<SubAccountEntity>>> whereSubAccountType(
    Iterable<SubAccountType> accountsTypes,
  );
  Future<Either<Failure, List<SubAccountEntity>>> whereStoresAccounts(
    int periodId,
  );
  Future<Either<Failure, List<SubAccountEntity>>> whereMainAccountId(
    Iterable<int> ids,
  );
  Future<Either<Failure, double>> getBalance(int subAccountId);
  Future<Either<Failure, int>> getCountHistories(int subAccountId);
  Future<Either<Failure, int>> getCountCreditorHistories(int subAccountId);
  Future<Either<Failure, int>> getCountDebtorHistories(int subAccountId);
  Future<Either<Failure, double>> getDebtorBalance(int branchAccountId);
  Future<Either<Failure, double>> getCreditorBalance(int branchAccountId);

  Future<Either<Failure, SubAccountEntity?>> firstWhereMainAccount(
    int mainAccountId,
  );
  Future<Either<Failure, SubAccountEntity>> getGoodsCost({
    required int personId,
    required int periodId,
  });
  Future<Either<Failure, bool>> updateBalances({
    required double incrementBalance,
    required double decrementBalance,
    required int incrementsCountHistories,
    required int decrementsCountHistories,
    required int id,
  });
  Future<Either<Failure, bool>> changeDefaultAccount({
    required int id,
    required int mainAccountId,
  });
  Future<Either<Failure, bool>> updateBalance({
    required bool isIncrement,
    required double amount,
    required int id,
  });
  Future<Either<Failure, List<SubAccountEntity>>> whereWarehouse(
    int warehouseId,
  );
  Future<Either<Failure, List<SubAccountEntity>>> whereAccountType(
    Iterable<SubAccountType> types,
  );
  Future<Either<Failure, List<SubAccountEntity>>> wherePerson(
    int personId,
    int warehouseId,
  );
  Future<Either<Failure, SubAccountEntity?>> firstWhereMainAccountAndPerson(
    int mainAccountId,
    int personId,
  );
  Future<Either<Failure, List<DataRecord>>> whereAccountNameLike({
    required String contains,
    List<SubAccountType> types = const [],
  });
  Future<Either<Failure, List<SubAccountSimpleEntity>>>
  getAccountsWhereMainAccountId(int mainAccountId);
  Future<Either<Failure, List<SubAccountSimpleEntity>>> getSubAccountsSimple({
    required String query,
  });
}
