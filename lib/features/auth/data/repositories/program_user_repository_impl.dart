import 'package:fpdart/fpdart.dart';
import 'package:flowcash/features/auth/data/datasources/interfaces/program_user_data_source.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/user_permission_enum.dart';
import 'package:flowcash/core/enums/user_status_enum.dart';
import 'package:flowcash/features/auth/domain/repositories/program_user_repository.dart';

class ProgramUserRepositoryImpl implements ProgramUserRepository {
  final ProgramUserDataSource _dataSource;

  const ProgramUserRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProgramUserEntity>>> get({Iterable<int>? ids}) async {
    try {
      final users = await _dataSource.get(ids: ids);
      return right(users);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramUserEntity?>> getById(int id) async {
    try {
      final user = await _dataSource.getById(id);
      return right(user);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramUserEntity>> insert(ProgramUserEntity entity) async {
    try {
      await _dataSource.insert(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramUserEntity>> update(ProgramUserEntity entity) async {
    try {
      await _dataSource.update(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return right(true);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramUserEntity?>> getUserWhereArgs({
    required String userName,
    required String password,
    required UserStatus status,
    required UserPermission permission,
  }) async {
    try {
      final user = await _dataSource.getUserWhereArgs(
        userName: userName,
        password: password,
        status: status,
        permission: permission,
      );
      return right(user);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgramUserEntity>>> whereIsNotAdmin() async {
    try {
      final users = await _dataSource.whereIsNotAdmin();
      return right(users);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramUserEntity?>> firstWhereUserNameAndPassword(
    String userName,
    String password,
  ) async {
    try {
      final user = await _dataSource.firstWhereUserNameAndPassword(userName, password);
      return right(user);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
