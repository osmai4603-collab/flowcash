import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class InventoryHistoryRepository {
  Future<Either<Failure, List<InventoryHistory>>> getHistories();
}
