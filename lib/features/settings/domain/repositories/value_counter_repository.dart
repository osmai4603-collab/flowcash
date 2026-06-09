import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/repositories/interfaces/value_counter_repository.dart' as core_repo;

abstract class ValueCounterRepository implements core_repo.ValueCounterRepository {
  Future<Either<Failure, ValueCounterEntity>> getCounter(ValueCounterType type);
  Future<Either<Failure, int>> incrementCounter(ValueCounterType type);
  Future<Either<Failure, ValueCounterEntity>> setCounter(
    ValueCounterEntity counter,
  );
}
