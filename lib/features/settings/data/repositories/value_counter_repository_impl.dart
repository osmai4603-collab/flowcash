import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../../domain/entities/value_counter_entity.dart';
import '../../domain/repositories/value_counter_repository.dart';
import '../datasources/interfaces/value_counter_data_source.dart';

class ValueCounterRepositoryImpl implements ValueCounterRepository {
  final ValueCounterDataSource _dataSource;

  const ValueCounterRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ValueCounterEntity>> getCounter(ValueCounterType type) async {
    try {
      final counter = await _dataSource.getCounter(type);
      return right(counter);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> incrementCounter(ValueCounterType type) async {
    try {
      final nextValue = await _dataSource.incrementCounter(type);
      return right(nextValue);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
