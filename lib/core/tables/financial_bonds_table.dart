import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الأسناد المالية.
class FinancialBondsTable extends TableInfo {
  static final FinancialBondsTable _instance = FinancialBondsTable.internal();

  factory FinancialBondsTable() => _instance;

  FinancialBondsTable.internal();

  @override
  final String tableName = 'financial_bonds';

  final String id = 'bond_id';
  final String createdAt = 'create_at';
  final String createdBy = 'created_by';
  final String note = 'note';
  final String offerAmount = 'amount';
  final String currencyId = 'currency_id';
  final String billNumber = 'bill_number';
  final String warehouseId = 'warehouse_id';
  final String journalEntryId = 'journal_entry_id';
  final String hintId = 'hint_id';
  final String bondType = 'bond_type';

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
    bondType,];
}
