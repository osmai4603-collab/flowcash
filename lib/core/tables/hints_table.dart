import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول البيانات (التلميحات).
class HintsTable extends TableById {
  static final HintsTable _instance = HintsTable.internal();

  factory HintsTable() => _instance;

  HintsTable.internal();

  @override
  final String tableName = 'hints';

  final String id = 'hint_id';
  final String hintName = 'hint_name';
  final String hintType = 'hint_type';

  @override
  List<String> get columns => [id, hintName, hintType];
}
