import 'package:flowcash/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/app_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_local_data_source.dart';
import '../models/app_model.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource localDataSource;

  AppRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppEntity>> getAppData() async {
    try {
      final appData = await localDataSource.getAppData();
      return Right(appData);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAppData(AppEntity appData) async {
    try {
      final appModel = AppModel(
        themeMode: appData.themeMode,
        locale: appData.locale,
      );
      await localDataSource.saveAppData(appModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
