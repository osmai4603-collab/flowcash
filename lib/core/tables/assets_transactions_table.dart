import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول حركات الأصول.
class AssetsTransactionsTable extends TableInfo {
  static final AssetsTransactionsTable _instance =
      AssetsTransactionsTable.internal();

  factory AssetsTransactionsTable() => _instance;

  AssetsTransactionsTable.internal();

  @override
  final String tableName = 'assets_transactions';

  final String id = 'asset_id';
  final String createdAt = 'create_at';
  final String createdBy = 'created_by';
  final String note = 'note';
  final String offerAmount = 'amount';
  final String currencyId = 'currency_id';
  final String billNumber = 'bill_number';
  final String warehouseId = 'warehouse_id';
  final String journalEntryId = 'journal_entry_id';
  final String hintId = 'hint_id';
  final String historyGroup = 'history_group';

  @override
  List<String> get columns => [
    id,
    createdAt,
    createdBy,
    note,
    offerAmount,
    currencyId,
    billNumber,
    warehouseId,
    journalEntryId,
    hintId,
    historyGroup,
  ];
}
