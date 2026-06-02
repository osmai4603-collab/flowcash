/// ثوابت جدول طلبيات الفواتير.
class BillOrdersTable {
  const BillOrdersTable._();

  static const String tableName = 'bills_orders';

  static const String id = 'order_id';
  static const String billId = 'bill_id';
  static const String categoryId = 'category_id';
  static const String countUnits = 'count_units';
  static const String totalPrice = 'total_price';
  static const String orderType = 'order_type';
  static const String inventoryId = 'inventory_id';
  static const String batchId = 'batch_id';

  static const List<String> fields = [
    id,
    categoryId,
    countUnits,
    billId,
    totalPrice,
    orderType,
    inventoryId,
    batchId,
  ];
}
