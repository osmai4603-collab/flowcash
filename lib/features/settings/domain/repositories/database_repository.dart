import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';

abstract class DatabaseRepository {
  Future<Either<Failure, String>> backupDatabase(String destinationPath);
  Future<Either<Failure, void>> restoreDatabase(String sourcePath);
}
