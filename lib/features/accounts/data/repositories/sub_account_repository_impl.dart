import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/entities/data_record.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

class SubAccountRepositoryImpl implements SubAccountRepository {
  final SubAccountDataSource _dataSource;
  const SubAccountRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<SubAccountEntity>>> get({
    Iterable<int>? ids,
  }) async {
    try {
      final res = await _dataSource.get(ids: ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity?>> getById(int id) async {
    try {
      final res = await _dataSource.getById(id);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity>> insert(
    SubAccountEntity entity,
  ) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return Right(entityInserted);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity>> update(
    SubAccountEntity entity,
  ) async {
    try {
      final entityUpdated = await _dataSource.update(entity);
      return Right(entityUpdated);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return const Right(true);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereMainAccount(
    int mainAccountId,
  ) async {
    try {
      final res = await _dataSource.whereMainAccount(mainAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereSubAccountType(
    Iterable<SubAccountType> accountsTypes,
  ) async {
    try {
      final res = await _dataSource.whereSubAccountType(accountsTypes);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereStoresAccounts(
    int periodId,
  ) async {
    try {
      final res = await _dataSource.whereStoresAccounts(periodId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereMainAccountId(
    Iterable<int> ids,
  ) async {
    try {
      final res = await _dataSource.whereMainAccountId(ids);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance(int subAccountId) async {
    try {
      final res = await _dataSource.getBalance(subAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCountHistories(int subAccountId) async {
    try {
      final res = await _dataSource.getCountHistories(subAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCountCreditorHistories(
    int subAccountId,
  ) async {
    try {
      final res = await _dataSource.getCountCreditorHistories(subAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCountDebtorHistories(int subAccountId) async {
    try {
      final res = await _dataSource.getCountDebtorHistories(subAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getDebtorBalance(int branchAccountId) async {
    try {
      final res = await _dataSource.getDebtorBalance(branchAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getCreditorBalance(
    int branchAccountId,
  ) async {
    try {
      final res = await _dataSource.getCreditorBalance(branchAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity?>> firstWhereMainAccount(
    int mainAccountId,
  ) async {
    try {
      final res = await _dataSource.firstWhereMainAccount(mainAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity>> getGoodsCost({
    required int personId,
    required int periodId,
  }) async {
    try {
      final res = await _dataSource.getGoodsCost(
        personId: personId,
        periodId: periodId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBalances({
    required double debitBalance,
    required double creditBalance,
    required int incrementsCountHistories,
    required int decrementsCountHistories,
    required int id,
  }) async {
    try {
      final res = await _dataSource.updateBalances(
        debitBalance: debitBalance,
        creditBalance: creditBalance,
        incrementsCountHistories: incrementsCountHistories,
        decrementsCountHistories: decrementsCountHistories,
        id: id,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changeDefaultAccount({
    required int id,
    required int mainAccountId,
  }) async {
    try {
      final res = await _dataSource.changeDefaultAccount(
        id: id,
        mainAccountId: mainAccountId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBalance({
    required bool isIncrement,
    required double amount,
    required int id,
  }) async {
    try {
      final res = await _dataSource.updateBalance(
        isIncrement: isIncrement,
        amount: amount,
        id: id,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereWarehouse(
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereWarehouse(warehouseId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> whereAccountTypeAndWarehouse(
    Iterable<SubAccountType> types,
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereAccountTypeAndWarehouse(
        types,
        warehouseId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountEntity>>> wherePerson(
    int personId,
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.wherePerson(personId, warehouseId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubAccountEntity?>> firstWhereMainAccountAndPerson(
    int mainAccountId,
    int personId,
  ) async {
    try {
      final res = await _dataSource.firstWhereMainAccountAndPerson(
        mainAccountId,
        personId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DataRecord>>> whereAccountNameLike({
    required String contains,
    List<SubAccountType> types = const [],
  }) async {
    try {
      final res = await _dataSource.whereAccountNameLike(
        contains: contains,
        types: types,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountSimpleEntity>>>
  getAccountsWhereMainAccountId(int mainAccountId) async {
    try {
      final res = await _dataSource.getAccountsWhereMainAccountId(
        mainAccountId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubAccountSimpleEntity>>> getSubAccountsSimple({
    required String query,
  }) async {
    try {
      final res = await _dataSource.getSubAccountsSimple(query: query);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
