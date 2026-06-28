import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الحركات المالية.
class FinancialTransactionsTable extends TableInfo {
  static final FinancialTransactionsTable _instance = FinancialTransactionsTable.internal();

  factory FinancialTransactionsTable() => _instance;

  FinancialTransactionsTable.internal();

  @override
  final String tableName = 'financial_transactions';

  final String id = 'tran_id';
  final String createdAt = 'create_at';
  final String createdBy = 'created_by';
  final String note = 'note';
  final String offerAmount = 'amount';
  final String currencyId = 'currency_id';
  final String billNumber = 'bill_number';
  final String warehouseId = 'warehouse_id';
  final String journalEntryId = 'journal_entry_id';
  final String hintId = 'hint_id';
  final String transactionType = 'tran_type';

  @override
  List<String> get columns => [id,
    createdAt,
    createdBy,
    note,
    offerAmount,
    currencyId,
    billNumber,
    warehouseId,
    journalEntryId,
    hintId,
    transactionType,];
}
