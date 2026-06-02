import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FinancialBondRepository implements RepositoryDB<FinancialBondEntity> {
  @override
  Future<Either<Failure, List<FinancialBondEntity>>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  });
}
