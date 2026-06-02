/// ثوابت جدول الوحدات.
class UnitsTable {
  const UnitsTable._();

  static const String tableName = 'units';
  static const String id = 'unit_id';
  static const String unitType = 'unit_type';
  static const String unitName = 'unit_name';
  static const String length = 'length';
  static const String width = 'width';
  static const String thickness = 'thickness';

  static const List<String> fields = [
    id,
    unitType,
    unitName,
    length,
    width,
    thickness,
  ];
}
