import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../../entities/app_value_entity.dart';
import '../../repositories/app_value_repository.dart';

class GetValueByType {
  final AppValueRepository repository;

  GetValueByType(this.repository);

  Future<Either<Failure, AppValueEntity>> call(AppValueType type) async {
    return await repository.getValueByType(type);
  }
}
