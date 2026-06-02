import 'package:flowcash/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/app_entity.dart';
import '../repositories/app_repository.dart';

class SaveAppData {
  final AppRepository repository;

  SaveAppData(this.repository);

  Future<Either<Failure, void>> call(AppEntity params) async {
    return await repository.saveAppData(params);
  }
}
