/// ثوابت جدول الأصناف الرئيسية.
class MainCategoriesTable {
  const MainCategoriesTable._();

  static const String tableName = 'main_categories';

  static const String id = 'category_id';

  static const String categoryName = 'category_name';
  static const String unitType = 'unit_type';
  static const String categoryType = 'category_type';
  static const String unitName = 'unit_name';

  static const List<String> fields = [
    id,
    categoryName,
    unitType,
    categoryType,
    unitName,
  ];
}
