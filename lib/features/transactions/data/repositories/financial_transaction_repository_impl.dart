import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_transaction_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_transaction_data_source.dart';

class FinancialTransactionRepositoryImpl implements FinancialTransactionRepository {
  final FinancialTransactionDataSource _dataSource;

  const FinancialTransactionRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<FinancialTransactionEntity>>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  }) async {
    try {
      final result = await _dataSource.get(ids: ids, historyGroup: historyGroup);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialTransactionEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialTransactionEntity>> insert(
      FinancialTransactionEntity entity) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return right(entityInserted);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialTransactionEntity>> update(
      FinancialTransactionEntity entity) async {
    try {
      final entityUpdated = await _dataSource.update(entity);
      return right(entityUpdated);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final deleted = await _dataSource.delete(id);
      return right(deleted);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
