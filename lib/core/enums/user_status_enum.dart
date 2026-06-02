import 'app_enum.dart';

sealed class UserStatus extends AppEnum {
  final String typeName;

  const UserStatus({required this.typeName});

  static const enabled = EnabledUserStatus._();
  static const stopped = StoppedUserStatus._();

  static const List<UserStatus> values = [enabled, stopped];

  static UserStatus of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown UserStatus: $name'),
    );
  }

  @override
  String get name;

  @override
  int get index;

  @override
  String displayName() => typeName;
}

final class EnabledUserStatus extends UserStatus {
  const EnabledUserStatus._() : super(typeName: 'مفعل');

  @override
  String get name => 'enabled';

  @override
  int get index => 0;
}

final class StoppedUserStatus extends UserStatus {
  const StoppedUserStatus._() : super(typeName: 'موقف');

  @override
  String get name => 'stopped';

  @override
  int get index => 1;
}
