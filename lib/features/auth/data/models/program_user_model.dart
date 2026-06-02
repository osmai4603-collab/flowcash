import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/enums/user_type_enum.dart';
import '../../domain/entities/program_user_entity.dart';

final class ProgramUserModel extends ProgramUserEntity {
  const ProgramUserModel({
    required super.id,
    required super.userName,
    required super.password,
    required super.userType,
    required super.warehouseId,
  });

  factory ProgramUserModel.fromMap(Map<String, dynamic> map) {
    final typeName = map[ProgramUsersTable.userType] as String? ?? '';
    return ProgramUserModel(
      id: map[ProgramUsersTable.id] ?? 0,
      userName: map[ProgramUsersTable.userName]?.toString() ?? '',
      password: map[ProgramUsersTable.password]?.toString() ?? '',
      userType: _typeFromName(typeName),
      warehouseId: map[ProgramUsersTable.warehouseId] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ProgramUsersTable.userName: userName,
      ProgramUsersTable.password: password,
      ProgramUsersTable.userType: userType.name,
      ProgramUsersTable.warehouseId: warehouseId,
    };
  }

  @override
  ProgramUserModel copyWith({
    int? id,
    String? userName,
    String? password,
    UserType? userType,
    int? warehouseId,
  }) {
    return ProgramUserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      warehouseId: warehouseId ?? this.warehouseId,
    );
  }

  static UserType _typeFromName(String name) {
    try {
      return UserType.of(name);
    } catch (_) {
      return UserType.user;
    }
  }
}
