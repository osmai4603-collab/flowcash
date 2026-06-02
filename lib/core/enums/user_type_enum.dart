import 'app_enum.dart';

sealed class UserType extends AppEnum {
  const UserType();

  static const admin = AdminUserType._();
  static const manager = ManagerUserType._();
  static const user = UserUserType._();

  static const List<UserType> values = [
    admin,
    manager,
    user,
  ];

  static UserType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown UserType: $name'),
    );
  }
}

final class AdminUserType extends UserType {
  const AdminUserType._();

  @override
  String get name => 'admin';

  @override
  int get index => 0;

  @override
  String displayName() => 'مدير النظام';
}

final class ManagerUserType extends UserType {
  const ManagerUserType._();

  @override
  String get name => 'manager';

  @override
  int get index => 1;

  @override
  String displayName() => 'مدير';
}

final class UserUserType extends UserType {
  const UserUserType._();

  @override
  String get name => 'user';

  @override
  int get index => 2;

  @override
  String displayName() => 'مستخدم';
}
