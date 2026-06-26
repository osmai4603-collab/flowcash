import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/goods_costs_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';

/// Creates SQLite triggers for managing inventory value (cost_total)
/// when goods costs are inserted, updated, or deleted.
final class GoodsCostBalanceTrigger {
  const GoodsCostBalanceTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS goods_costs_after_insert_balance');
    db.execute('DROP TRIGGER IF EXISTS goods_costs_after_update_balance');
    db.execute('DROP TRIGGER IF EXISTS goods_costs_after_delete_balance');

    // 1. Insert Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS goods_costs_after_insert_balance
      AFTER INSERT ON ${GoodsCostsTable.tableName}
      WHEN NEW.${GoodsCostsTable.orderId} IS NOT NULL
      BEGIN
        UPDATE ${InventoriesTable.tableName}
        SET ${InventoriesTable.costTotal} = ${InventoriesTable.costTotal} - NEW.${GoodsCostsTable.offerAmount}
        WHERE ${InventoriesTable.id} = (
          SELECT inv.${InventoriesTable.id}
          FROM ${BillOrdersTable.tableName} o
          JOIN ${InventoriesTable.tableName} inv ON inv.${InventoriesTable.categoryId} = o.${BillOrdersTable.categoryId}
          WHERE o.${BillOrdersTable.id} = NEW.${GoodsCostsTable.orderId}
          LIMIT 1
        );
      END;
    ''');

    // 2. Update Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS goods_costs_after_update_balance
      AFTER UPDATE ON ${GoodsCostsTable.tableName}
      WHEN NEW.${GoodsCostsTable.orderId} IS NOT NULL
      BEGIN
        -- Reverse old value
        UPDATE ${InventoriesTable.tableName}
        SET ${InventoriesTable.costTotal} = ${InventoriesTable.costTotal} + OLD.${GoodsCostsTable.offerAmount}
        WHERE ${InventoriesTable.id} = (
          SELECT inv.${InventoriesTable.id}
          FROM ${BillOrdersTable.tableName} o
          JOIN ${InventoriesTable.tableName} inv ON inv.${InventoriesTable.categoryId} = o.${BillOrdersTable.categoryId}
          WHERE o.${BillOrdersTable.id} = OLD.${GoodsCostsTable.orderId}
          LIMIT 1
        );

        -- Apply new value
        UPDATE ${InventoriesTable.tableName}
        SET ${InventoriesTable.costTotal} = ${InventoriesTable.costTotal} - NEW.${GoodsCostsTable.offerAmount}
        WHERE ${InventoriesTable.id} = (
          SELECT inv.${InventoriesTable.id}
          FROM ${BillOrdersTable.tableName} o
          JOIN ${InventoriesTable.tableName} inv ON inv.${InventoriesTable.categoryId} = o.${BillOrdersTable.categoryId}
          WHERE o.${BillOrdersTable.id} = NEW.${GoodsCostsTable.orderId}
          LIMIT 1
        );
      END;
    ''');

    // 3. Delete Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS goods_costs_after_delete_balance
      AFTER DELETE ON ${GoodsCostsTable.tableName}
      WHEN OLD.${GoodsCostsTable.orderId} IS NOT NULL
      BEGIN
        UPDATE ${InventoriesTable.tableName}
        SET ${InventoriesTable.costTotal} = ${InventoriesTable.costTotal} + OLD.${GoodsCostsTable.offerAmount}
        WHERE ${InventoriesTable.id} = (
          SELECT inv.${InventoriesTable.id}
          FROM ${BillOrdersTable.tableName} o
          JOIN ${InventoriesTable.tableName} inv ON inv.${InventoriesTable.categoryId} = o.${BillOrdersTable.categoryId}
          WHERE o.${BillOrdersTable.id} = OLD.${GoodsCostsTable.orderId}
          LIMIT 1
        );
      END;
    ''');
  }
}
