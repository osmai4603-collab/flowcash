import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/features/settings/data/models/value_counter_model.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/repositories/interfaces/value_counter_repository.dart';
import '../datasources/interfaces/value_counter_data_source.dart';

class ValueCounterRepositoryImpl implements ValueCounterRepository {
  final ValueCounterDataSource _dataSource;

  const ValueCounterRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ValueCounterEntity>> getCounter(
    ValueCounterType type,
  ) async {
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

  @override
  Future<Either<Failure, ValueCounterEntity>> setCounter(
    ValueCounterEntity counter,
  ) async {
    try {
      final model = ValueCounterModel(
        id: counter.id,
        counterType: counter.counterType,
        count: counter.count,
        counterMax: counter.counterMax,
        incrementValue: counter.incrementValue,
        formatValue: counter.formatValue,
      );
      final updated = await _dataSource.setCounter(model);
      return right(updated);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ValueCounterEntity>> getValueCounterByCounterType(
    ValueCounterType counterType,
  ) async {
    try {
      final counter = await _dataSource.getValueCounterByCounterType(
        counterType,
      );
      return right(counter);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final result = await _dataSource.delete(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ValueCounterEntity>>> get({
    Iterable<int>? ids,
  }) async {
    try {
      final result = await _dataSource.get(ids: ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ValueCounterEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ValueCounterEntity>> insert(
    ValueCounterEntity entity,
  ) async {
    try {
      final result = await _dataSource.insert(entity);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ValueCounterEntity>> update(
    ValueCounterEntity entity,
  ) async {
    try {
      final result = await _dataSource.update(entity);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getNextCounter(int valueGroupId) async {
    // Note: The settings data source doesn't have getNextCounter by ID directly,
    // but we can implement it using incrementCounter if we know the type,
    // or just throw not implemented if it's not used.
    // However, the core interface requires it.
    // For now, let's try to get by ID and then increment by type.
    try {
      final entity = await _dataSource.getById(valueGroupId);
      if (entity == null) return left(DatabaseFailure('Counter not found'));
      final nextValue = await _dataSource.incrementCounter(entity.counterType);
      return right(nextValue);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getNextCounterByGroup(
    HistoriesGroup historyGroup,
  ) async {
    // Maps HistoriesGroup to ValueCounterType if possible, or handle specifically.
    // For simplicity, if they share names:
    try {
      final type = ValueCounterType.values.firstWhere(
        (e) => e.name == historyGroup.name,
      );
      final nextValue = await _dataSource.incrementCounter(type);
      return right(nextValue);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
