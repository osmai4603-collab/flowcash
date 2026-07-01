import 'package:flowcash/core/services/sqlite/sqlite_database_manager.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import '../../domain/repositories/database_repository.dart';

class DatabaseRepositoryImpl implements DatabaseRepository {
  final SqliteDatabaseManager _sqliteManager;

  DatabaseRepositoryImpl(this._sqliteManager);

  @override
  Future<Either<Failure, String>> backupDatabase(String destinationPath) async {
    try {
      final file = await _sqliteManager.copyDatabase(destinationPath);
      return Right(file.path);
    } catch (e) {
      return Left(DatabaseFailure('فشل النسخ الاحتياطي لقاعدة البيانات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreDatabase(String sourcePath) async {
    try {
      await _sqliteManager.restoreDatabase(sourcePath);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('فشل استعادة قاعدة البيانات: ${e.toString()}'));
    }
  }
}
