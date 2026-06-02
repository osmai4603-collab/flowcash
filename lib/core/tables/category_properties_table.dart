/// ثوابت جدول خصائص الأصناف.
class CategoryPropertiesTable {
  const CategoryPropertiesTable._();

  static const String tableName = 'categories_properties';

  static const String id = 'property_id';
  
  static const String mainCategoryId = 'main_category_id';
  static const String propertyName = 'property_name';
  static const String unitType = 'unit_type';
  static const String isSingle = 'is_single';
  static const String isCategoryUnit = 'is_category_unit';
  static const String isPricingUnit = 'is_pricing_unit';
  static const String isInventoryUnit = 'is_inventory_unit';

  static const List<String> fields = [
    id,
    mainCategoryId,
    propertyName,
    unitType,
    isSingle,
    isCategoryUnit,
    isPricingUnit,
    isInventoryUnit,
  ];
}
