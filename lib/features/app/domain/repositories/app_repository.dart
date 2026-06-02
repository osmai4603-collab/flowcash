import 'package:flowcash/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/app_entity.dart';

abstract class AppRepository {
  Future<Either<Failure, AppEntity>> getAppData();
  Future<Either<Failure, void>> saveAppData(AppEntity appData);
}
