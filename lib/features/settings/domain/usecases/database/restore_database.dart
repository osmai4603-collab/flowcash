import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../repositories/database_repository.dart';

class RestoreDatabaseUseCase {
  final DatabaseRepository repository;

  RestoreDatabaseUseCase(this.repository);

  Future<Either<Failure, void>> call(String sourcePath) async {
    return await repository.restoreDatabase(sourcePath);
  }
}
