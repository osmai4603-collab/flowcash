import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../entities/app_value_entity.dart';

abstract class AppValueRepository {
  Future<Either<Failure, List<AppValueEntity>>> getAllValues();
  Future<Either<Failure, AppValueEntity>> getValueByType(AppValueType type);
  Future<Either<Failure, bool>> updateValue(AppValueEntity value);
  Future<Either<Failure, AppValueEntity>> getLocalCurrency();
  Future<Either<Failure, List<AppValueEntity>>> getCompanyInfo();
}
