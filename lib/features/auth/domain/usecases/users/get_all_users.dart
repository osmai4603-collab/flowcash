import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/program_user_entity.dart';
import '../../repositories/program_user_repository.dart';

class GetAllUsers {
  final ProgramUserRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, List<ProgramUserEntity>>> call() async {
    return await repository.get();
  }
}
