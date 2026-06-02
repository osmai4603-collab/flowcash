import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/app_value_entity.dart';
import '../../repositories/app_value_repository.dart';

class UpdateValue {
  final AppValueRepository repository;

  UpdateValue(this.repository);

  Future<Either<Failure, bool>> call(AppValueEntity value) async {
    return await repository.updateValue(value);
  }
}
