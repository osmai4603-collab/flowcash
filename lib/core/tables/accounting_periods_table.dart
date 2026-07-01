import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الفترات المحاسبية.
class AccountingPeriodsTable extends TableById {
  static final AccountingPeriodsTable _instance =
      AccountingPeriodsTable.internal();

  factory AccountingPeriodsTable() => _instance;

  AccountingPeriodsTable.internal();

  @override
  final String tableName = 'accounting_periods';

  @override
  final String id = 'period_id';
  final String balance = 'money_head';
  final String currencyId = 'currency_id';
  final String lastPeriodId = 'last_period_id';
  final String periodName = 'period_name';
  final String dateOfStartPeriod = 'start_date';
  final String dateOfEndPeriod = 'end_date';
  final String inventoryType = 'inventory_type';

  @override
  List<String> get columns => [
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
