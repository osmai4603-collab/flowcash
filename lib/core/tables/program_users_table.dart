/// ثوابت جدول مستخدمي البرنامج.
class ProgramUsersTable {
  const ProgramUsersTable._();

  static const String tableName = 'program_users';

  static const String id = 'user_id';
  static const String userName = 'user_name';
  static const String password = 'password';
  static const String userType = 'user_type';
  static const String warehouseId = 'warehouse_id';

  static const List<String> fields = [
    id,
    userName,
    password,
    userType,
    warehouseId,
  ];
}
