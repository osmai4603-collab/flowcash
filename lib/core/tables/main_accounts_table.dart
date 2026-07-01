import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الحسابات الرئيسية.
class MainAccountsTable extends TableById {
  static final MainAccountsTable _instance = MainAccountsTable.internal();

  factory MainAccountsTable() => _instance;

  MainAccountsTable.internal();

  @override
  final String tableName = 'main_accounts';

  @override
  final String id = 'account_id';
  final String accountName = 'account_name';
  final String accountNumber = 'account_number';
  final String currencyId = 'currency_id';
  final String debitBalance = 'debit_balance';
  final String creditBalance = 'credit_balance';
  final String mainAccountType = 'type';
  final String numbersCounter = 'counter_acc';

  @override
  List<String> get columns => [id,
    accountName,
    accountNumber,
    currencyId,
    debitBalance,
    creditBalance,
    numbersCounter,
    mainAccountType,];
}
