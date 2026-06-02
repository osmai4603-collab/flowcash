import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import 'package:flowcash/core/enums/user_permission_enum.dart';
import 'package:flowcash/core/enums/user_status_enum.dart';

abstract interface class ProgramUserDataSource implements AppDataSource<int, ProgramUserEntity, Map<String, dynamic>> {
  Future<ProgramUserEntity?> getUserWhereArgs({
    required String userName,
    required String password,
    required UserStatus status,
    required UserPermission permission,
  });

  Future<List<ProgramUserEntity>> whereIsNotAdmin();

  Future<ProgramUserEntity?> firstWhereUserNameAndPassword(String userName, String password);
}
