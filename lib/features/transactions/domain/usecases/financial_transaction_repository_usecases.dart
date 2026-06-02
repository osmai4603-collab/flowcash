import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_transaction_repository.dart';

/// UseCases for FinancialTransactionRepository

class GetFinancialTransactionsUseCase {
  final FinancialTransactionRepository _repository;

  const GetFinancialTransactionsUseCase(this._repository);

  Future<Either<Failure, List<FinancialTransactionEntity>>> call({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  }) async {
    return await _repository.get(ids: ids, historyGroup: historyGroup);
  }
}

class GetFinancialTransactionByIdUseCase {
  final FinancialTransactionRepository _repository;

  const GetFinancialTransactionByIdUseCase(this._repository);

  Future<Either<Failure, FinancialTransactionEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertFinancialTransactionUseCase {
  final FinancialTransactionRepository _repository;

  const InsertFinancialTransactionUseCase(this._repository);

  Future<Either<Failure, FinancialTransactionEntity>> call(
    FinancialTransactionEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateFinancialTransactionUseCase {
  final FinancialTransactionRepository _repository;

  const UpdateFinancialTransactionUseCase(this._repository);

  Future<Either<Failure, FinancialTransactionEntity>> call(
    FinancialTransactionEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteFinancialTransactionUseCase {
  final FinancialTransactionRepository _repository;

  const DeleteFinancialTransactionUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
