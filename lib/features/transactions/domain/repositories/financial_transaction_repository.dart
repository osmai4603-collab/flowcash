import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FinancialTransactionRepository
    implements RepositoryDB<FinancialTransactionEntity> {
  @override
  Future<Either<Failure, List<FinancialTransactionEntity>>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  });
}
