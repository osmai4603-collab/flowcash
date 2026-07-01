import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول طلبيات الفواتير.
class BillOrdersTable extends TableById {
  static final BillOrdersTable _instance = BillOrdersTable.internal();

  factory BillOrdersTable() => _instance;

  BillOrdersTable.internal();

  @override
  final String tableName = 'bills_orders';

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
