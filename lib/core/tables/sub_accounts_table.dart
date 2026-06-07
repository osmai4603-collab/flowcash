/// ثوابت جدول الحسابات الفرعية.
class SubAccountsTable {
  const SubAccountsTable._();

  static const String tableName = 'sub_accounts';

  static const String id = 'account_id';
  static const String accountName = 'account_name';
  static const String mainAccountId = 'main_account_id';
  static const String accountNumber = 'number';
  static const String debitBalance = 'debit_balance';
  static const String creditBalance = 'credit_balance';
  static const String currencyId = 'currency_id';
  static const String balanceMax = 'balance_max';
  static const String subAccountType = 'sub_account_type';
  static const String createdAt = 'account_date';

  static const List<String> fields = [
    id,
    accountName,
    accountNumber,
    mainAccountId,
    currencyId,
    debitBalance,
    creditBalance,
    balanceMax,
    subAccountType,
    createdAt,
  ];
}
