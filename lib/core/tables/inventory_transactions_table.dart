import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الحركات المخزنية.
class InventoryTransactionsTable extends TableById {
  static final InventoryTransactionsTable _instance = InventoryTransactionsTable.internal();

  factory InventoryTransactionsTable() => _instance;

  InventoryTransactionsTable.internal();

  @override
  final String tableName = 'inventory_transactions';

  final String id = 'tran_id';
  final String createdAt = 'create_at';
  final String createdBy = 'created_by';
  final String note = 'note';
  final String warehouseId = 'store_id';
  final String personId = 'person_id';
  final String billNumber = 'bill_number';
  final String transactionType = 'tran_type';
  final String transactionNature = 'tran_nature';

  @override
  List<String> get columns => [
        id,
        createdAt,
        createdBy,
        note,
        warehouseId,
        personId,
        billNumber,
        transactionType,
        transactionNature,
      ];
}

