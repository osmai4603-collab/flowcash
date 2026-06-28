import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_schema_manager.dart';
import 'package:flowcash/core/services/sqlite/sqlite_default_data.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';

void main() {
  // Override sqlite3 library path for Linux VM
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  group('Inventory Database Triggers Tests', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
      db.execute('PRAGMA foreign_keys = ON');
      SqliteSchemaManager.createAll(db);
      DefaultDataInserter.insertDefaults(db);
    });

    tearDown(() {
      db.dispose();
    });

    test('InventoryBalanceTrigger should update inventory balance on insert, update, and delete of orders', () {
      final nowStr = DateTime.now().toIso8601String();

      // 1. Create a dummy category
      db.execute('''
        INSERT INTO categories (category_id, category_type, category_name, category_number)
        VALUES (999, 'material', 'إسمنت مقاوم', 'CAT-999')
      ''');

      // 2. Insert Inventory with initial count_units = 0
      db.execute('''
        INSERT INTO inventories (
          inventory_id, category_id, store_id, property_id, revenue_id, expense_id,
          income_stock_id, outcome_stock_id, cost_total, count_units, user_id
        ) VALUES (888, 999, 1, 801, 805, 806, 803, 804, 0.0, 0.0, 1)
      ''');

      // Ensure initial units are 0
      var inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 0.0);

      // 3. Create Inward Transaction (import_inventory) with 'purchases' nature
      db.execute('''
        INSERT INTO inventory_transactions (
          tran_id, create_at, created_by, note, store_id, tran_type, bill_number, tran_nature
        ) VALUES (1001, '$nowStr', 1, 'Inward Transaction', 1, 'import_inventory', 'BILL-1001', 'purchases')
      ''');

      // 4. Insert order for 10 units
      db.execute('''
        INSERT INTO inventory_transactions_orders (
          order_id, inventory_id, count_units, tran_id
        ) VALUES (5001, 888, 10.0, 1001)
      ''');

      // Verify that inventory balance is now 10
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 10.0);

      // 5. Update order to 25 units
      db.execute('''
        UPDATE inventory_transactions_orders
        SET count_units = 25.0
        WHERE order_id = 5001
      ''');

      // Verify that inventory balance is now 25
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 25.0);

      // 6. Create Outward Transaction (export_inventory) with 'sales' nature
      db.execute('''
        INSERT INTO inventory_transactions (
          tran_id, create_at, created_by, note, store_id, tran_type, bill_number, tran_nature
        ) VALUES (1002, '$nowStr', 1, 'Outward Transaction', 1, 'export_inventory', 'BILL-1002', 'sales')
      ''');

      // 7. Insert outward order for 5 units
      db.execute('''
        INSERT INTO inventory_transactions_orders (
          order_id, inventory_id, count_units, tran_id
        ) VALUES (5002, 888, 5.0, 1002)
      ''');

      // Verify that inventory balance is now 20 (25 - 5)
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 20.0);

      // 8. Update outward order to 12 units
      db.execute('''
        UPDATE inventory_transactions_orders
        SET count_units = 12.0
        WHERE order_id = 5002
      ''');

      // Verify that inventory balance is now 13 (25 - 12)
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 13.0);

      // 9. Delete outward order
      db.execute('DELETE FROM inventory_transactions_orders WHERE order_id = 5002');

      // Verify that inventory balance is back to 25
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 25.0);

      // 10. Delete inward order
      db.execute('DELETE FROM inventory_transactions_orders WHERE order_id = 5001');

      // Verify that inventory balance is back to 0
      inventoryRow = db.select('SELECT count_units FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['count_units'], 0.0);
    });

    test('CostGoodBalanceTrigger should update inventory cost_total on insert, update, and delete of cost good bill orders', () {
      final nowStr = DateTime.now().toIso8601String();

      // 1. Create a dummy category
      db.execute('''
        INSERT INTO categories (category_id, category_type, category_name, category_number)
        VALUES (999, 'material', 'إسمنت مقاوم', 'CAT-999')
      ''');

      // 2. Insert Inventory with initial cost_total = 1000.0
      db.execute('''
        INSERT INTO inventories (
          inventory_id, category_id, store_id, property_id, revenue_id, expense_id,
          income_stock_id, outcome_stock_id, cost_total, count_units, user_id
        ) VALUES (888, 999, 1, 801, 805, 806, 803, 804, 1000.0, 10.0, 1)
      ''');

      // 3. Create dummy person (needed as foreign key in bills)
      db.execute('''
        INSERT INTO persons (person_id, person_name, person_type)
        VALUES (15, 'عميل تجريبي', 'customer')
      ''');

      // 4. Create Sales Bill (sales)
      db.execute('''
        INSERT INTO bills (
          bill_id, create_at, create_by, amount, currency_id, bill_number, warehouse_id, person_id, is_cash, bill_type
        ) VALUES (101, '$nowStr', 1, 1200.0, 'YER', 101, 1, 15, 0, 'sales')
      ''');

      // 5. Create Cost Good Bill (representing cost of the sales bill)
      db.execute('''
        INSERT INTO cost_good_bills (
          cost_good_bill_id, create_at, create_by, amount, currency_id, bill_number, warehouse_id, person_id, bill_id
        ) VALUES (201, '$nowStr', 1, 300.0, 'YER', 101, 1, 15, 101)
      ''');

      // 6. Insert cost good bill order for 300.0 (decreases cost_total because it is a sale)
      db.execute('''
        INSERT INTO cost_good_bill_orders (
          order_id, bill_id, category_id, count_units, total_price
        ) VALUES (301, 201, 999, 5.0, 300.0)
      ''');

      // Verify that inventory cost_total is now 700.0 (1000 - 300)
      var inventoryRow = db.select('SELECT cost_total FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['cost_total'], 700.0);

      // 7. Update cost good bill order total_price to 450.0
      db.execute('''
        UPDATE cost_good_bill_orders
        SET total_price = 450.0
        WHERE order_id = 301
      ''');

      // Verify that inventory cost_total is now 550.0 (1000 - 450)
      inventoryRow = db.select('SELECT cost_total FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['cost_total'], 550.0);

      // 8. Delete cost good bill order
      db.execute('DELETE FROM cost_good_bill_orders WHERE order_id = 301');

      // Verify that inventory cost_total reverts to 1000.0
      inventoryRow = db.select('SELECT cost_total FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['cost_total'], 1000.0);

      // 9. Create Sales Return Bill (sales_return)
      db.execute('''
        INSERT INTO bills (
          bill_id, create_at, create_by, amount, currency_id, bill_number, warehouse_id, person_id, is_cash, bill_type
        ) VALUES (102, '$nowStr', 1, 1200.0, 'YER', 102, 1, 15, 0, 'sales_return')
      ''');

      // 10. Create Cost Good Bill for Sales Return
      db.execute('''
        INSERT INTO cost_good_bills (
          cost_good_bill_id, create_at, create_by, amount, currency_id, bill_number, warehouse_id, person_id, bill_id
        ) VALUES (202, '$nowStr', 1, 150.0, 'YER', 102, 1, 15, 102)
      ''');

      // 11. Insert cost good bill order for 150.0 (increases cost_total because it is a sales return)
      db.execute('''
        INSERT INTO cost_good_bill_orders (
          order_id, bill_id, category_id, count_units, total_price
        ) VALUES (302, 202, 999, 2.0, 150.0)
      ''');

      // Verify that inventory cost_total is now 1150.0 (1000 + 150)
      inventoryRow = db.select('SELECT cost_total FROM inventories WHERE inventory_id = 888').first;
      expect(inventoryRow['cost_total'], 1150.0);
    });
  });
}
