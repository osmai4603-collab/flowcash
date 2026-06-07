/// ثوابت جدول الحسابات الرئيسية.
class MainAccountsTable {
  const MainAccountsTable._();

  static const String tableName = 'main_accounts';

  static const String id = 'account_id';
  static const String accountName = 'account_name';
  static const String accountNumber = 'account_number';
  static const String currencyId = 'currency_id';
  static const String debitBalance = 'debit_balance';
  static const String creditBalance = 'credit_balance';
  static const String mainAccountType = 'type';
  static const String numbersCounter = 'counter_acc';

  static const List<String> fields = [
    id,
    accountName,
    accountNumber,
    currencyId,
    debitBalance,
    creditBalance,
    numbersCounter,
    mainAccountType,
  ];
}
