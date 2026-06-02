/// ثوابت جدول البيانات (التلميحات).
class HintsTable {
  const HintsTable._();

  static const String tableName = 'hints';

  static const String id = 'hint_id';
  static const String hintName = 'hint_name';
  static const String hintType = 'hint_type';

  static const List<String> fields = [
    id,
    hintName,
    hintType,
  ];
}
