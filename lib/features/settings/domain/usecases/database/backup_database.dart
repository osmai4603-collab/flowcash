import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../repositories/database_repository.dart';

class BackupDatabaseUseCase {
  final DatabaseRepository repository;

  BackupDatabaseUseCase(this.repository);

  Future<Either<Failure, String>> call(String destinationPath) async {
    return await repository.backupDatabase(destinationPath);
  }
}
