import 'app_enum.dart';

sealed class UserPermission extends AppEnum {
  final String typeName;

  const UserPermission({required this.typeName});

  static const admin = AdminUserPermission._();
  static const subAdmin = SubAdminUserPermission._();

  static const List<UserPermission> values = [admin, subAdmin];

  static UserPermission of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown UserPermission: $name'),
    );
  }

  @override
  String get name;

  @override
  int get index;

  @override
  String displayName() => typeName;
}

final class AdminUserPermission extends UserPermission {
  const AdminUserPermission._() : super(typeName: 'مدير النظام');

  @override
  String get name => 'admin';

  @override
  int get index => 0;
}

final class SubAdminUserPermission extends UserPermission {
  const SubAdminUserPermission._() : super(typeName: 'مدير عام');

  @override
  String get name => 'subAdmin';

  @override
  int get index => 1;
}
