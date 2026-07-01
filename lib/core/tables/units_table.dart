import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الوحدات.
class UnitsTable extends TableById {
  static final UnitsTable _instance = UnitsTable.internal();

  factory UnitsTable() => _instance;

  UnitsTable.internal();

  @override
  final String tableName = 'units';

  final String id = 'unit_id';
  final String unitType = 'unit_type';
  final String unitName = 'unit_name';
  final String length = 'length';
  final String width = 'width';
  final String thickness = 'thickness';

  @override
  List<String> get columns => [id,
    unitType,
    unitName,
    length,
    width,
    thickness,];
}
