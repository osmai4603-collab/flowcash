import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class ValueCounterRepository
    implements RepositoryDB<ValueCounterEntity> {
  Future<Either<Failure, int>> getNextCounter(int valueGroupId);

  Future<Either<Failure, int>> getNextCounterByGroup(
    HistoriesGroup historyGroup,
  );
}
