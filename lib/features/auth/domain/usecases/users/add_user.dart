import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/program_user_entity.dart';
import '../../repositories/program_user_repository.dart';

class AddUser {
  final ProgramUserRepository repository;

  AddUser(this.repository);

  Future<Either<Failure, ProgramUserEntity>> call(ProgramUserEntity user) async {
    return await repository.insert(user);
  }
}
