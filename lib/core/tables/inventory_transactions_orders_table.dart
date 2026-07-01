import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول طلبيات حركة المخزون.
class InventoryTransactionsOrdersTable extends TableById {
  static final InventoryTransactionsOrdersTable _instance = InventoryTransactionsOrdersTable.internal();

  factory InventoryTransactionsOrdersTable() => _instance;

  InventoryTransactionsOrdersTable.internal();

  @override
  final String tableName = 'inventory_transactions_orders';

  final String id = 'order_id';
  final String inventoryId = 'inventory_id';
  final String countUnits = 'count_units';
  final String tranId = 'tran_id';

  @override
  List<String> get columns => [id,
    inventoryId,
    countUnits,
    tranId,];
}
