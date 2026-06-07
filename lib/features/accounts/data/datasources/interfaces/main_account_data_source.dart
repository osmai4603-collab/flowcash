import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';

abstract interface class MainAccountDataSource implements AppDataSource<int, MainAccountEntity, Map<String, dynamic>> {
  Future<List<MainAccountEntity>> whereAccountGroup(MainAccountGroup accountType, int periodId);
  Future<List<MainAccountEntity>> whereMainAccountType(MainAccountType belongGroup, int warehouseId);
  Future<List<MainAccountEntity>> whereAccountType(Iterable<MainAccountType> belongGroup, int warehouseId);
  Future<List<MainAccountEntity>> whereAccountsGroups(Iterable<MainAccountGroup> types, int warehouseId);
  Future<int?> getMaxAccountNumber(MainAccountGroup accountType);
  Future<List<MainAccountEntity>> whereWarehouse(int warehouseId);
  Future<bool> updateCounter({required int counter, required int id});
  Future<bool> updateBalances({required double debitBalance, required double creditBalance, required int id});
  Future<bool> updateBalance({required bool isIncrement, required double amount, required int subAccountId});
  Future<MainAccountEntity> firstWhereSubAccountId(int subAccountId);
}
