/// ثوابت جدول الحسابات الفرعية.
class SubAccountsTable {
  const SubAccountsTable._();

  static const String tableName = 'sub_accounts';

  static const String id = 'account_id';
  static const String accountName = 'account_name';
  static const String mainAccountId = 'main_account_id';
  static const String accountNumber = 'number';
  static const String debit = 'debit_balance';
  static const String credit = 'credit_balance';
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
    debit,
    credit,
    balanceMax,
    subAccountType,
    createdAt,
  ];
}
