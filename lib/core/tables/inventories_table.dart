/// ثوابت جدول البضائع (المخزون).
class InventoriesTable {
  const InventoriesTable._();

  static const String tableName = 'inventories';

  static const String id = 'inventory_id';
  static const String categoryId = 'category_id';
  static const String storeId = 'store_id';
  static const String propertyAccountId = 'property_id';
  static const String revenueAccountId = 'revenue_id';
  static const String expenseAccountId = 'expense_id';
  static const String incomeStockId = 'income_stock_id';
  static const String outcomeStockId = 'outcome_stock_id';
  static const String costTotal = 'cost_total';
  static const String countUnits = 'count_units';
  static const String userId = 'user_id';

  static const List<String> fields = [
    id,
    categoryId,
    storeId,
    propertyAccountId,
    revenueAccountId,
    expenseAccountId,
    incomeStockId,
    outcomeStockId,
    costTotal,
    countUnits,
    userId,
  ];
}
