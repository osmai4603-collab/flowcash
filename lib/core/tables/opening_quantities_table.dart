/// ثوابت جدول الكميات الإفتتاحية.
class OpeningQuantitiesTable {
  const OpeningQuantitiesTable._();

  static const String tableName = 'opening_quantities';

  static const String id = 'opening_id';
  static const String categoryId = 'category_id';
  static const String countUnits = 'count_units';
  static const String warehouseId = 'store_id';
  static const String createdAt = 'create_at';
  static const String costTotal = 'cost_total';
  static const String periodId = 'period_id';

  static const List<String> fields = [
    id,
    categoryId,
    countUnits,
    warehouseId,
    createdAt,
    costTotal,
    periodId,
  ];
}
