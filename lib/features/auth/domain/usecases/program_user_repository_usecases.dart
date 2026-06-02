import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import 'package:flowcash/core/enums/user_permission_enum.dart';
import 'package:flowcash/core/enums/user_status_enum.dart';
import 'package:flowcash/features/auth/domain/repositories/program_user_repository.dart';

/// UseCases for ProgramUserRepository

class GetProgramUsersUseCase {
  final ProgramUserRepository _repository;

  const GetProgramUsersUseCase(this._repository);

  Future<Either<Failure, List<ProgramUserEntity>>> call({
    Iterable<int>? ids,
  }) async {
    return await _repository.get(ids: ids);
  }
}

class GetProgramUserByIdUseCase {
  final ProgramUserRepository _repository;

  const GetProgramUserByIdUseCase(this._repository);

  Future<Either<Failure, ProgramUserEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertProgramUserUseCase {
  final ProgramUserRepository _repository;

  const InsertProgramUserUseCase(this._repository);

  Future<Either<Failure, ProgramUserEntity>> call(
    ProgramUserEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateProgramUserUseCase {
  final ProgramUserRepository _repository;

  const UpdateProgramUserUseCase(this._repository);

  Future<Either<Failure, ProgramUserEntity>> call(
    ProgramUserEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteProgramUserUseCase {
  final ProgramUserRepository _repository;

  const DeleteProgramUserUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class GetUserWhereArgsUseCase {
  final ProgramUserRepository _repository;

  const GetUserWhereArgsUseCase(this._repository);

  Future<Either<Failure, ProgramUserEntity?>> call({
    required String userName,
    required String password,
    required UserStatus status,
    required UserPermission permission,
  }) async {
    return await _repository.getUserWhereArgs(
      userName: userName,
      password: password,
      status: status,
      permission: permission,
    );
  }
}

class FirstWhereUserNameAndPasswordUseCase {
  final ProgramUserRepository _repository;

  const FirstWhereUserNameAndPasswordUseCase(this._repository);

  Future<Either<Failure, ProgramUserEntity?>> call(
    String userName,
    String password,
  ) async {
    return await _repository.firstWhereUserNameAndPassword(userName, password);
  }
}
