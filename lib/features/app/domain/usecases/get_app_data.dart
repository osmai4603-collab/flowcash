import 'package:flowcash/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/app_entity.dart';
import '../repositories/app_repository.dart';

class GetAppData {
  final AppRepository repository;

  GetAppData(this.repository);

  Future<Either<Failure, AppEntity>> call() async {
    return await repository.getAppData();
  }
}
