import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';

abstract interface class InventoryHistoryRepository {
  Future<List<InventoryHistory>> getHistories();
}
