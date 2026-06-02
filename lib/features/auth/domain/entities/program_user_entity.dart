import 'package:flowcash/core/enums/user_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class ProgramUserEntity extends Entity {
  final int id;
  final String userName;
  final String password;
  final UserType userType;
  final int warehouseId;

  const ProgramUserEntity({
    this.id = 0,
    this.userName = '',
    this.password = '',
    this.userType = UserType.user,
    this.warehouseId = 0,
  });

  @override
  List<Object?> get props => [id, userName, password, userType, warehouseId];

  @override
  ProgramUserEntity copyWith({
    int? id,
    String? userName,
    String? password,
    UserType? userType,
    int? warehouseId,
  }) {
    return ProgramUserEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      warehouseId: warehouseId ?? this.warehouseId,
    );
  }
}
