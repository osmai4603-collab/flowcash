import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class MainAccountRepository
    implements RepositoryDB<MainAccountEntity> {
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountGroup(
    MainAccountGroup accountType,
    int periodId,
  );
  Future<Either<Failure, List<MainAccountEntity>>> whereMainAccountType(
    MainAccountType belongGroup,
    int warehouseId,
  );
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountType(
    Iterable<MainAccountType> belongGroup,
    int warehouseId,
  );
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountsGroups(
    Iterable<MainAccountGroup> types,
    int warehouseId,
  );
  Future<Either<Failure, int?>> getMaxAccountNumber(
    MainAccountGroup accountType,
  );
  Future<Either<Failure, List<MainAccountEntity>>> whereWarehouse(
    int warehouseId,
  );
  Future<Either<Failure, bool>> updateCounter({
    required int counter,
    required int id,
  });
  Future<Either<Failure, bool>> updateBalances({
    required double debitBalance,
    required double creditBalance,
    required int id,
  });
  Future<Either<Failure, bool>> updateBalance({
    required bool isIncrement,
    required double amount,
    required int subAccountId,
  });
  Future<Either<Failure, MainAccountEntity>> firstWhereSubAccountId(
    int subAccountId,
  );
}
