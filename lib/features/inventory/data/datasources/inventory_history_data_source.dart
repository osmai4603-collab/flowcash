import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';

abstract interface class InventoryHistoryDataSource {
  Future<List<InventoryHistory>> getHistories();
}
