import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول طلبيات تكلفة الفواتير المباعة.
class CostGoodBillOrdersTable extends TableInfo {
  static final CostGoodBillOrdersTable _instance = CostGoodBillOrdersTable.internal();

  factory CostGoodBillOrdersTable() => _instance;

  CostGoodBillOrdersTable.internal();

  @override
  final String tableName = 'cost_good_bill_orders';

  final String id = 'order_id';
  final String billId = 'bill_id';
  final String categoryId = 'category_id';
  final String countUnits = 'count_units';
  final String totalPrice = 'total_price';

  @override
  List<String> get columns => [id,
    categoryId,
    countUnits,
    billId,
    totalPrice,];
}
