/// ثوابت جدول الكتالوجات.
class SubcategoriesTable {
  const SubcategoriesTable._();

  static const String tableName = 'subcategories';

  static const String id = 'catalog_id';
  static const String mainCategoryId = 'main_category_id';
  static const String catalogName = 'catalog_name';
  static const String catalogNumber = 'catalog_number';

  static const List<String> fields = [
    id,
    mainCategoryId,
    catalogName,
    catalogNumber,
  ];
}
