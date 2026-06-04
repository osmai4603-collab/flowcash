/// ثوابت جدول طلبيات حركة المخزون.
class InventoryTransactionsOrdersTable {
  const InventoryTransactionsOrdersTable._();

  static const String tableName = 'inventory_transactions_orders';

  static const String id = 'order_id';
  static const String inventoryId = 'inventory_id';
  static const String countUnits = 'count_units';
  static const String tranId = 'tran_id';
  static const String transactionType = 'tran_type';

  static const List<String> fields = [
    id,
    inventoryId,
    countUnits,
    tranId,
    transactionType,
  ];
}
