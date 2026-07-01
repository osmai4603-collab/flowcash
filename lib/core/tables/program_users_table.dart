import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول مستخدمي البرنامج.
class ProgramUsersTable extends TableById {
  static final ProgramUsersTable _instance = ProgramUsersTable.internal();

  factory ProgramUsersTable() => _instance;

  ProgramUsersTable.internal();

  @override
  final String tableName = 'program_users';

  final String id = 'user_id';
  final String userName = 'user_name';
  final String password = 'password';
  final String userType = 'user_type';
  final String warehouseId = 'warehouse_id';

  @override
  List<String> get columns => [id,
    userName,
    password,
    userType,
    warehouseId,];
}
