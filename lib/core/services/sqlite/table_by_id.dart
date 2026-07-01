import 'package:flowcash/core/services/sqlite/table_info.dart';

/// كلاس مجرد يمثل جدول يحتوي على حقل معرف (ID).
abstract class TableById extends TableInfo {
  const TableById();

  /// اسم حقل المعرف في الجدول.
  String get id;
}
