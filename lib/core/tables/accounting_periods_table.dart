/// ثوابت جدول الفترات المحاسبية.
class AccountingPeriodsTable {
  const AccountingPeriodsTable._();

  static const String tableName = 'accounting_periods';

  static const String id = 'period_id';
  static const String balance = 'money_head';
  static const String currencyId = 'currency_id';
  static const String lastPeriodId = 'last_period_id';
  static const String periodName = 'period_name';
  static const String dateOfStartPeriod = 'start_date';
  static const String dateOfEndPeriod = 'end_date';
  static const String inventoryType = 'inventory_type';

  static const List<String> fields = [
    id,
    balance,
    currencyId,
    lastPeriodId,
    periodName,
    dateOfStartPeriod,
    dateOfEndPeriod,
    inventoryType,
  ];
}
