import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/main_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/main_account_repository.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';

class MainAccountRepositoryImpl implements MainAccountRepository {
  final MainAccountDataSource _dataSource;
  const MainAccountRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<MainAccountEntity>>> get({
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
  Future<Either<Failure, MainAccountEntity?>> getById(int id) async {
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
  Future<Either<Failure, MainAccountEntity>> insert(
    MainAccountEntity entity,
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
  Future<Either<Failure, MainAccountEntity>> update(
    MainAccountEntity entity,
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
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountGroup(
    MainAccountGroup accountType,
    int periodId,
  ) async {
    try {
      final res = await _dataSource.whereAccountGroup(accountType, periodId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MainAccountEntity>>> whereMainAccountType(
    MainAccountType belongGroup,
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereMainAccountType(
        belongGroup,
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
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountType(
    Iterable<MainAccountType> belongGroup,
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereAccountType(belongGroup, warehouseId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MainAccountEntity>>> whereAccountsGroups(
    Iterable<MainAccountGroup> types,
    int warehouseId,
  ) async {
    try {
      final res = await _dataSource.whereAccountsGroups(types, warehouseId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int?>> getMaxAccountNumber(
    MainAccountGroup accountType,
  ) async {
    try {
      final res = await _dataSource.getMaxAccountNumber(accountType);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MainAccountEntity>>> whereWarehouse(
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
  Future<Either<Failure, bool>> updateCounter({
    required int counter,
    required int id,
  }) async {
    try {
      final res = await _dataSource.updateCounter(counter: counter, id: id);
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
    required int id,
  }) async {
    try {
      final res = await _dataSource.updateBalances(
        debitBalance: debitBalance,
        creditBalance: creditBalance,
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
  Future<Either<Failure, bool>> updateBalance({
    required bool isIncrement,
    required double amount,
    required int subAccountId,
  }) async {
    try {
      final res = await _dataSource.updateBalance(
        isIncrement: isIncrement,
        amount: amount,
        subAccountId: subAccountId,
      );
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MainAccountEntity>> firstWhereSubAccountId(
    int subAccountId,
  ) async {
    try {
      final res = await _dataSource.firstWhereSubAccountId(subAccountId);
      return Right(res);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
