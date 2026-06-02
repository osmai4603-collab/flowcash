/// ثوابت جدول معلومات الكتالوج.
class SubcategoriesUnitsTable {
  const SubcategoriesUnitsTable._();

  static const String tableName = 'subcategories_units';

  static const String id = 'info_id';
  static const String subcategoryId = 'subcategory_id';
  static const String unitId = 'unit_id';

  static const List<String> fields = [id, subcategoryId, unitId, propertyId];

  static const propertyId = 'property_id';
}
