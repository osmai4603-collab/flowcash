import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_bond_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_bond_data_source.dart';

class FinancialBondRepositoryImpl implements FinancialBondRepository {
  final FinancialBondDataSource _dataSource;

  const FinancialBondRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<FinancialBondEntity>>> get({
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
  Future<Either<Failure, FinancialBondEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialBondEntity>> insert(
      FinancialBondEntity entity) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return right(entityInserted);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialBondEntity>> update(
      FinancialBondEntity entity) async {
    try {
      await _dataSource.update(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return right(true);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
