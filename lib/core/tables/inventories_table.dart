import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول البضائع (المخزون).
class InventoriesTable extends TableById {
  static final InventoriesTable _instance = InventoriesTable.internal();

  factory InventoriesTable() => _instance;

  InventoriesTable.internal();

  @override
  final String tableName = 'inventories';

  final String id = 'inventory_id';
  final String categoryId = 'category_id';
  final String storeId = 'store_id';
  final String propertyAccountId = 'property_id';
  final String revenueAccountId = 'revenue_id';
  final String expenseAccountId = 'expense_id';
  final String incomeStockId = 'income_stock_id';
  final String outcomeStockId = 'outcome_stock_id';
  final String costTotal = 'cost_total';
  final String countUnits = 'count_units';
  final String userId = 'user_id';

  @override
  List<String> get columns => [id,
    categoryId,
    storeId,
    propertyAccountId,
    revenueAccountId,
    expenseAccountId,
    incomeStockId,
    outcomeStockId,
    costTotal,
    countUnits,
    userId,];
}
