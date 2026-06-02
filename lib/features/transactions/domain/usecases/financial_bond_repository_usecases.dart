import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_bond_repository.dart';

/// UseCases for FinancialBondRepository

class GetFinancialBondsUseCase {
  final FinancialBondRepository _repository;

  const GetFinancialBondsUseCase(this._repository);

  Future<Either<Failure, List<FinancialBondEntity>>> call({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  }) async {
    return await _repository.get(ids: ids, historyGroup: historyGroup);
  }
}

class GetFinancialBondByIdUseCase {
  final FinancialBondRepository _repository;

  const GetFinancialBondByIdUseCase(this._repository);

  Future<Either<Failure, FinancialBondEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertFinancialBondUseCase {
  final FinancialBondRepository _repository;

  const InsertFinancialBondUseCase(this._repository);

  Future<Either<Failure, FinancialBondEntity>> call(
    FinancialBondEntity entity,
  ) async {
    return await _repository.insert(entity);
  }
}

class UpdateFinancialBondUseCase {
  final FinancialBondRepository _repository;

  const UpdateFinancialBondUseCase(this._repository);

  Future<Either<Failure, FinancialBondEntity>> call(
    FinancialBondEntity entity,
  ) async {
    return await _repository.update(entity);
  }
}

class DeleteFinancialBondUseCase {
  final FinancialBondRepository _repository;

  const DeleteFinancialBondUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
