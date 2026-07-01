import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الحسابات الفرعية.
class SubAccountsTable extends TableById {
  static final SubAccountsTable _instance = SubAccountsTable.internal();

  factory SubAccountsTable() => _instance;

  SubAccountsTable.internal();

  @override
  final String tableName = 'sub_accounts';

  final String id = 'account_id';
  final String accountName = 'account_name';
  final String mainAccountId = 'main_account_id';
  final String accountNumber = 'number';
  final String incrementBalance = 'increment_balance';
  final String decrementBalance = 'decrement_balance';
  final String currencyId = 'currency_id';
  final String balanceMax = 'balance_max';
  final String subAccountType = 'sub_account_type';
  final String createdAt = 'account_date';

  @override
  List<String> get columns => [id,
    accountName,
    accountNumber,
    mainAccountId,
    currencyId,
    incrementBalance,
    decrementBalance,
    balanceMax,
    subAccountType,
    createdAt,];
}
