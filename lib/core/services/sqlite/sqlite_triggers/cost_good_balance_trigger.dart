import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

/// Creates SQLite triggers for managing inventory costs (cost_total)
/// when cost of goods bill orders are inserted, updated, or deleted.
final class CostGoodBalanceTrigger {
  const CostGoodBalanceTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS cost_good_orders_after_insert_balance');
    db.execute('DROP TRIGGER IF EXISTS cost_good_orders_after_update_balance');
    db.execute('DROP TRIGGER IF EXISTS cost_good_orders_after_delete_balance');

    // 1. Insert Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS cost_good_orders_after_insert_balance
      AFTER INSERT ON ${CostGoodBillOrdersTable().tableName}
      BEGIN
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().costTotal} = ${InventoriesTable().costTotal} + (
          CASE 
            WHEN (SELECT ${BillsTable().billType} FROM ${BillsTable().tableName} WHERE ${BillsTable().id} = (SELECT ${CostGoodBillsTable().billId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = NEW.${CostGoodBillOrdersTable().billId})) = 'sales_return' 
            THEN NEW.${CostGoodBillOrdersTable().totalPrice}
            ELSE -NEW.${CostGoodBillOrdersTable().totalPrice}
          END
        )
        WHERE ${InventoriesTable().categoryId} = NEW.${CostGoodBillOrdersTable().categoryId}
          AND ${InventoriesTable().storeId} = (SELECT ${CostGoodBillsTable().warehouseId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = NEW.${CostGoodBillOrdersTable().billId});
      END;
    ''');

    // 2. Update Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS cost_good_orders_after_update_balance
      AFTER UPDATE ON ${CostGoodBillOrdersTable().tableName}
      BEGIN
        -- Reverse old value
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().costTotal} = ${InventoriesTable().costTotal} - (
          CASE 
            WHEN (SELECT ${BillsTable().billType} FROM ${BillsTable().tableName} WHERE ${BillsTable().id} = (SELECT ${CostGoodBillsTable().billId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = OLD.${CostGoodBillOrdersTable().billId})) = 'sales_return' 
            THEN OLD.${CostGoodBillOrdersTable().totalPrice}
            ELSE -OLD.${CostGoodBillOrdersTable().totalPrice}
          END
        )
        WHERE ${InventoriesTable().categoryId} = OLD.${CostGoodBillOrdersTable().categoryId}
          AND ${InventoriesTable().storeId} = (SELECT ${CostGoodBillsTable().warehouseId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = OLD.${CostGoodBillOrdersTable().billId});

        -- Apply new value
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().costTotal} = ${InventoriesTable().costTotal} + (
          CASE 
            WHEN (SELECT ${BillsTable().billType} FROM ${BillsTable().tableName} WHERE ${BillsTable().id} = (SELECT ${CostGoodBillsTable().billId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = NEW.${CostGoodBillOrdersTable().billId})) = 'sales_return' 
            THEN NEW.${CostGoodBillOrdersTable().totalPrice}
            ELSE -NEW.${CostGoodBillOrdersTable().totalPrice}
          END
        )
        WHERE ${InventoriesTable().categoryId} = NEW.${CostGoodBillOrdersTable().categoryId}
          AND ${InventoriesTable().storeId} = (SELECT ${CostGoodBillsTable().warehouseId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = NEW.${CostGoodBillOrdersTable().billId});
      END;
    ''');

    // 3. Delete Trigger
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS cost_good_orders_after_delete_balance
      AFTER DELETE ON ${CostGoodBillOrdersTable().tableName}
      BEGIN
        UPDATE ${InventoriesTable().tableName}
        SET ${InventoriesTable().costTotal} = ${InventoriesTable().costTotal} - (
          CASE 
            WHEN (SELECT ${BillsTable().billType} FROM ${BillsTable().tableName} WHERE ${BillsTable().id} = (SELECT ${CostGoodBillsTable().billId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = OLD.${CostGoodBillOrdersTable().billId})) = 'sales_return' 
            THEN OLD.${CostGoodBillOrdersTable().totalPrice}
            ELSE -OLD.${CostGoodBillOrdersTable().totalPrice}
          END
        )
        WHERE ${InventoriesTable().categoryId} = OLD.${CostGoodBillOrdersTable().categoryId}
          AND ${InventoriesTable().storeId} = (SELECT ${CostGoodBillsTable().warehouseId} FROM ${CostGoodBillsTable().tableName} WHERE ${CostGoodBillsTable().id} = OLD.${CostGoodBillOrdersTable().billId});
      END;
    ''');
  }
}
