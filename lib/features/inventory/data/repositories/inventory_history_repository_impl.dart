import 'package:flowcash/features/inventory/data/datasources/inventory_history_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_history_repository.dart';

class InventoryHistoryRepositoryImpl implements InventoryHistoryRepository {
  final InventoryHistoryDataSource _dataSource;

  const InventoryHistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<InventoryHistory>> getHistories() {
    return _dataSource.getHistories();
  }
}
