import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/app_value_entity.dart';
import '../../repositories/app_value_repository.dart';

class GetCompanyInfo {
  final AppValueRepository repository;

  GetCompanyInfo(this.repository);

  Future<Either<Failure, List<AppValueEntity>>> call() async {
    return await repository.getCompanyInfo();
  }
}
