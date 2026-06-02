import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/app_value_entity.dart';
import '../../repositories/app_value_repository.dart';

class GetAllValues {
  final AppValueRepository repository;

  GetAllValues(this.repository);

  Future<Either<Failure, List<AppValueEntity>>> call() async {
    return await repository.getAllValues();
  }
}
