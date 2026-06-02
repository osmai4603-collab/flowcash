/// ثوابت جدول كتالوجات المخزون.
class InventorySubcategoriesTable {
  const InventorySubcategoriesTable._();

  static const String tableName = 'inventory_subcategories';

  static const String id = 'inv_subcat_id';
  static const String storeId = 'store_id';
  static const String catalogId = 'catalog_id';
  static const String revenueAccountId = 'revenue_id';
  static const String expenseAccountId = 'expense_id';
  static const String incomeStockId = 'income_stock_id';
  static const String outcomeStockId = 'outcome_stock_id';

  static const List<String> fields = [
    id,
    storeId,
    catalogId,
    revenueAccountId,
    expenseAccountId,
    incomeStockId,
    outcomeStockId,
  ];
}
