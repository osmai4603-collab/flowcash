/// ثوابت جدول طلبيات تكلفة الفواتير المباعة.
class CostGoodBillOrdersTable {
  const CostGoodBillOrdersTable._();

  static const String tableName = 'cost_good_bill_orders';

  static const String id = 'order_id';
  static const String billId = 'bill_id';
  static const String categoryId = 'category_id';
  static const String countUnits = 'count_units';
  static const String totalPrice = 'total_price';

  static const List<String> fields = [
    id,
    categoryId,
    countUnits,
    billId,
    totalPrice,
  ];
}
