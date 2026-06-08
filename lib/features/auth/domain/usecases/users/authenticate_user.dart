import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/program_user_entity.dart';
import '../../repositories/program_user_repository.dart';

class AuthenticateUser {
  final ProgramUserRepository repository;

  AuthenticateUser(this.repository);

  Future<Either<Failure, ProgramUserEntity?>> call(
    String userName,
    String password,
  ) async {
    return await repository.firstWhereUserNameAndPassword(userName, password);
  }
}
