import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/interfaces/value_counter_repository.dart';

class IncrementCounter {
  final ValueCounterRepository repository;

  IncrementCounter(this.repository);

  Future<Either<Failure, int>> call(ValueCounterType type) async {
    return await repository.incrementCounter(type);
  }
}
