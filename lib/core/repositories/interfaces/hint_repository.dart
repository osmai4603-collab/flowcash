import 'package:flowcash/core/enums/hint_type_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/system/domain/entities/hint_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class HintRepository implements RepositoryDB<HintEntity> {
  Future<Either<Failure, List<HintEntity>>> whereHintType(Iterable<HintType> hintTypes);
  Future<Either<Failure, List<HintEntity>>> whereBelongGroup(HistoriesGroup operation);
  Future<Either<Failure, Map<int, HintEntity>>> getWhereHintTypeAsMap(Iterable<HintType> hintTypes);
  Future<Either<Failure, HintEntity?>> whereHintTypeAndName(HistoriesGroup historyGroup, String hintName);
  Future<Either<Failure, HintEntity>> getHintType(HistoriesGroup mainAccountId, String name);
  Future<Either<Failure, HintEntity>> getHintTypeAndName(HistoriesGroup mainAccountId, String hintName);
}
