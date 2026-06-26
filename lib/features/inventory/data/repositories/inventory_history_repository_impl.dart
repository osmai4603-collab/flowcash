import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_history_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class InventoryHistoryRepositoryImpl implements InventoryHistoryRepository {
  final InventoryHistoryDataSource _dataSource;

  const InventoryHistoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<InventoryHistory>>> getHistories() async {
    try {
      final histories = await _dataSource.getHistories();
      return Right(histories);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
