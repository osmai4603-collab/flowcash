import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الفواتير.
class BillsTable extends TableInfo {
  static final BillsTable _instance = BillsTable.internal();

  factory BillsTable() => _instance;

  BillsTable.internal();

  @override
  final String tableName = 'bills';

  final String id = 'bill_id';
  final String createdAt = 'create_at';
  final String createdBy = 'create_by';
  final String note = 'note';
  final String offerAmount = 'amount';
  final String currencyId = 'currency_id';
  final String billNumber = 'bill_number';
  final String warehouseId = 'warehouse_id';
  final String journalEntryId = 'journal_entry_id';
  final String personId = 'person_id';
  final String inventoryTransactionId = 'inventory_transaction_id';
  final String isCash = 'is_cash';
  final String billType = 'bill_type';
  final String costGoodId = 'cost_good_id';
  final String treasuryId = 'treasury_id';

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
    personId,
    inventoryTransactionId,
    isCash,
    billType,
    costGoodId,
    treasuryId,];
}
