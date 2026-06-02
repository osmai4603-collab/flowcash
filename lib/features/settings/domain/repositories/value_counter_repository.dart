import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../entities/value_counter_entity.dart';

abstract class ValueCounterRepository {
  Future<Either<Failure, ValueCounterEntity>> getCounter(ValueCounterType type);
  Future<Either<Failure, int>> incrementCounter(ValueCounterType type);
}
