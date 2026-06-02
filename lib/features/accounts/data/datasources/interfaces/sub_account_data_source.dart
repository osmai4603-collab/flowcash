import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/core/entities/data_record.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

abstract interface class SubAccountDataSource implements AppDataSource<int, SubAccountEntity, Map<String, dynamic>> {
  Future<List<SubAccountEntity>> whereMainAccount(int mainAccountId);
  Future<List<SubAccountEntity>> whereSubAccountType(Iterable<SubAccountType> accountsTypes);
  Future<List<SubAccountEntity>> whereStoresAccounts(int periodId);
  Future<List<SubAccountEntity>> whereMainAccountId(Iterable<int> ids);
  Future<double> getBalance(int subAccountId);
  Future<int> getCountHistories(int subAccountId);
  Future<int> getCountCreditorHistories(int subAccountId);
  Future<int> getCountDebtorHistories(int subAccountId);
  Future<double> getDebtorBalance(int branchAccountId);
  Future<double> getCreditorBalance(int branchAccountId);
  Future<SubAccountEntity?> firstWhereMainAccount(int mainAccountId);
  Future<SubAccountEntity> getGoodsCost({required int personId, required int periodId});
  Future<bool> updateBalances({required double incrementBalance, required double decrementBalance, required int incrementsCountHistories, required int decrementsCountHistories, required int id});
  Future<bool> changeDefaultAccount({required int id, required int mainAccountId});
  Future<bool> updateBalance({required bool isIncrement, required double amount, required int id});
  Future<List<SubAccountEntity>> whereWarehouse(int warehouseId);
  Future<List<SubAccountEntity>> whereAccountTypeAndWarehouse(Iterable<SubAccountType> types, int warehouseId);
  Future<List<SubAccountEntity>> wherePerson(int personId, int warehouseId);
  Future<SubAccountEntity?> firstWhereMainAccountAndPerson(int mainAccountId, int personId);
  Future<List<DataRecord>> whereAccountNameLike({required String contains, List<SubAccountType> types = const []});
  Future<List<SubAccountSimpleEntity>> getAccountsWhereMainAccountId(int mainAccountId);
  Future<List<SubAccountSimpleEntity>> getSubAccountsSimple({required String query});
}
