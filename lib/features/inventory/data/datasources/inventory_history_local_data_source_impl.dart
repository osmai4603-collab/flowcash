import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_history_data_source.dart';
import 'package:flowcash/features/inventory/data/models/inventory_history_model.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';

class InventoryHistoryLocalDataSourceImpl implements InventoryHistoryDataSource {
  final SqliteService _db;

  const InventoryHistoryLocalDataSourceImpl(this._db);

  @override
  Future<List<InventoryHistory>> getHistories() async {
    final query = '''
      SELECT 
        ito.${InventoryTransactionsOrdersTable().id}, 
        it.${InventoryTransactionsTable().transactionType}, 
        ito.${InventoryTransactionsOrdersTable().countUnits}, 
        c.${CategoriesTable().categoryName}, 
        u.${UnitsTable().unitName}, 
        ito.${InventoryTransactionsOrdersTable().inventoryId}
      FROM ${InventoryTransactionsOrdersTable().tableName} ito
      JOIN ${InventoryTransactionsTable().tableName} it ON ito.${InventoryTransactionsOrdersTable().tranId} = it.${InventoryTransactionsTable().id}
      JOIN ${InventoriesTable().tableName} i ON ito.${InventoryTransactionsOrdersTable().inventoryId} = i.${InventoriesTable().id}
      JOIN ${CategoriesTable().tableName} c ON i.${InventoriesTable().categoryId} = c.${CategoriesTable().id}
      JOIN ${UnitsTable().tableName} u ON c.${CategoriesTable().categoryUnitId} = u.${UnitsTable().id}
      ORDER BY it.${InventoryTransactionsTable().createdAt} DESC
    ''';

    final result = await _db.rawQuery(query);
    return result.map((map) => InventoryHistoryModel.fromMap(map)).toList();
  }
}
