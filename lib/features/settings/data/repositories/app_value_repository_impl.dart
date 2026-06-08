import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../../domain/entities/app_value_entity.dart';
import '../../domain/repositories/app_value_repository.dart';
import '../datasources/interfaces/app_value_data_source.dart';
import '../models/app_value_model.dart';

class AppValueRepositoryImpl implements AppValueRepository {
  final AppValueDataSource _dataSource;

  const AppValueRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AppValueEntity>>> getAllValues() async {
    try {
      final values = await _dataSource.getAllValues();
      return right(values);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppValueEntity>> getValueByType(
    AppValueType type,
  ) async {
    try {
      final value = await _dataSource.getValueByType(type);
      return right(value);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateValue(AppValueEntity value) async {
    try {
      final model = AppValueModel(
        id: value.id,
        value: value.value,
        valueType: value.valueType,
      );
      final result = await _dataSource.updateValue(model);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppValueEntity>> getLocalCurrency() async {
    return getValueByType(AppValueType.defaultCurrency);
  }

  @override
  Future<Either<Failure, List<AppValueEntity>>> getCompanyInfo() async {
    final result = await getAllValues();
    return result.map((values) {
      return values
          .where(
            (value) =>
                value.valueType == AppValueType.companyName ||
                value.valueType == AppValueType.companyPhone ||
                value.valueType == AppValueType.companyAddress ||
                value.valueType == AppValueType.companyDescription,
          )
          .toList();
    });
  }
}
