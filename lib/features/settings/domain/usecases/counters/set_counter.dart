import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import '../../entities/value_counter_entity.dart';
import '../../repositories/value_counter_repository.dart';

class SetCounter {
  final ValueCounterRepository repository;

  SetCounter(this.repository);

  Future<Either<Failure, ValueCounterEntity>> call(
    ValueCounterEntity counter,
  ) async {
    return await repository.setCounter(counter);
  }
}
