import 'package:flowcash/core/enums/user_permission_enum.dart';
import 'package:flowcash/core/enums/user_status_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import '../entities/program_user_entity.dart';

abstract interface class ProgramUserRepository
    implements RepositoryDB<ProgramUserEntity> {
  Future<Either<Failure, ProgramUserEntity?>> getUserWhereArgs({
    required String userName,
    required String password,
    required UserStatus status,
    required UserPermission permission,
  });

  Future<Either<Failure, List<ProgramUserEntity>>> whereIsNotAdmin();

  Future<Either<Failure, ProgramUserEntity?>> firstWhereUserNameAndPassword(
    String userName,
    String password,
  );
}
