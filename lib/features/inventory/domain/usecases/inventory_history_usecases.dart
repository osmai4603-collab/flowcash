import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetInventoryHistoriesUseCase {
  final InventoryHistoryRepository _repository;

  const GetInventoryHistoriesUseCase(this._repository);

  Future<Either<Failure, List<InventoryHistory>>> call() async {
    return await _repository.getHistories();
  }
}
