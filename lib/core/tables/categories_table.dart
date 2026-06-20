/// ثوابت جدول الأصناف.
class CategoriesTable {
  const CategoriesTable._();

  static const String tableName = 'categories';

  static const String id = 'category_id';
  static const String categoryType = 'category_type';
  static const String categoryName = 'category_name';
  static const String categoryNumber = 'category_number';
  static const String barcode = 'barcode';
  static const String categoryUnitId = 'category_unit_id';
  static const String pricingUnitId = 'pricing_unit_id';
  static const String inventoryUnitId = 'inventory_unit_id';
  static const String subcategoryId = 'subcategory_id';

  static const List<String> fields = [
    id,
    categoryType,
    categoryNumber,
    categoryName,
    barcode,
    categoryUnitId,
    pricingUnitId,
    inventoryUnitId,
    subcategoryId,
  ];
}
