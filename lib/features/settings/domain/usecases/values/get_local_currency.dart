import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/app_value_entity.dart';
import '../../repositories/app_value_repository.dart';

class GetLocalCurrency {
  final AppValueRepository repository;

  GetLocalCurrency(this.repository);

  Future<Either<Failure, AppValueEntity>> call() async {
    return await repository.getLocalCurrency();
  }
}
