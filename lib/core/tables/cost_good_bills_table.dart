import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول تكلفة الفواتير المباعة.
class CostGoodBillsTable extends TableInfo {
  static final CostGoodBillsTable _instance = CostGoodBillsTable.internal();

  factory CostGoodBillsTable() => _instance;

  CostGoodBillsTable.internal();

  @override
  final String tableName = 'cost_good_bills';

  final String id = 'cost_good_bill_id';
  final String createdAt = 'create_at';
  final String createdBy = 'create_by';
  final String note = 'note';
  final String offerAmount = 'amount';
  final String currencyId = 'currency_id';
  final String billNumber = 'bill_number';
  final String warehouseId = 'warehouse_id';
  final String journalEntryId = 'journal_entry_id';
  final String personId = 'person_id';
  final String billId = 'bill_id';

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
    billId,];
}
