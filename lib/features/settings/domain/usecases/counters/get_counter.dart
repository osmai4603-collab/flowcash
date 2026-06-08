import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../../entities/value_counter_entity.dart';
import '../../repositories/value_counter_repository.dart';

class GetCounter {
  final ValueCounterRepository repository;

  GetCounter(this.repository);

  Future<Either<Failure, ValueCounterEntity>> call(
    ValueCounterType type,
  ) async {
    return await repository.getCounter(type);
  }
}
