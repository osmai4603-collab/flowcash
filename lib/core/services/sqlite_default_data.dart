import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

final class DefaultDataInserter {
  const DefaultDataInserter._();

  static void insertDefaults(Database db) {
    _insertCurrencies(db);
    _insertWarehouses(db);
    _insertProgramUsers(db);
    _insertUnits(db);
    _insertExchangePrices(db);
    _insertAccountingPeriod(db);
    _insertValuesCounterDefaults(db);
    _insertDefaultValues(db);
    // if (kDebugMode) _insertFurnitureTestData(db);
  }

  static void _insertDefaultValues(Database db) {
    try {
      final rs = db.select(
        'SELECT COUNT(*) AS cnt FROM ${ValuesTable.tableName}',
      );
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt == 0) {
        for (final vt in ValueType.values) {
          final v = vt.defaultValue.replaceAll("'", "''");
          final sql =
              "INSERT INTO ${ValuesTable.tableName} (${ValuesTable.value}, ${ValuesTable.valueType}) VALUES ('$v', '${vt.name}')";
          debugPrint(sql);
          db.execute(sql);
        }
      }
    } catch (e) {
      debugPrint('insert default values failed: $e');
    }
  }

  static void _insertValuesCounterDefaults(Database db) {
    try {
      final rs = db.select(
        'SELECT COUNT(*) AS cnt FROM ${ValuesCounterTable.tableName} WHERE ${ValuesCounterTable.counterType} = ?',
        [ValueCounterType.categoryNumber.name],
      );
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt == 0) {
        final sql =
            "INSERT INTO ${ValuesCounterTable.tableName} (${ValuesCounterTable.counterType}, ${ValuesCounterTable.count}, ${ValuesCounterTable.counterMax}, ${ValuesCounterTable.incrementValue}, ${ValuesCounterTable.formatValue}) VALUES ('${ValueCounterType.categoryNumber.name}', 1001, 99999, 1, '0000')";
        debugPrint(sql);
        db.execute(sql);
      }
    } catch (e) {
      debugPrint('insert default category number counter failed: $e');
    }
  }

  static void _insertProgramUsers(Database db) {
    try {
      final sql = 'SELECT COUNT(*) AS cnt FROM ${ProgramUsersTable.tableName}';
      debugPrint('Executing query: $sql');
      final rsp = db.select(sql);
      final cnt = rsp.isNotEmpty ? (rsp.first['cnt'] as int) : 0;
      if (cnt == 0) {
        // Insert default admin user with username/password = admin
        db.execute(
          "INSERT INTO ${ProgramUsersTable.tableName} (${ProgramUsersTable.userName}, ${ProgramUsersTable.password}, ${ProgramUsersTable.userType}, ${ProgramUsersTable.warehouseId}) VALUES ('admin', 'admin', 'admin', 1)",
        );
      }
    } catch (e) {
      debugPrint('insert default program users failed: $e');
    }
  }

  static void _insertCurrencies(Database db) {
    try {
      final sql = 'SELECT COUNT(*) AS cnt FROM ${CurrenciesTable.tableName}';
      debugPrint('Executing query: $sql');
      final rs = db.select(sql);
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt == 0) {
        final field =
            "${CurrenciesTable.id}, ${CurrenciesTable.currencyName}, ${CurrenciesTable.symbol}, ${CurrenciesTable.isDefault}";
        final sql =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('YER', 'يمني', 'ر.ي', 1)";
        debugPrint('Executing query: $sql');
        db.execute(sql);

        final sql2 =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('SAR', 'سعودي', 'ر.س', 0)";
        debugPrint(sql2);
        db.execute(sql2);

        final sql3 =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('USD', 'دولار', '\$', 0)";
        debugPrint(sql3);
        db.execute(sql3);
      }
    } catch (e) {
      debugPrint('insert default currencies failed: $e');
    }
  }

  static void _insertWarehouses(Database db) {
    try {
      final rsw = db.select(
        'SELECT COUNT(*) AS cnt FROM ${WarehousesTable.tableName}',
      );
      final cntw = rsw.isNotEmpty ? (rsw.first['cnt'] as int) : 0;
      if (cntw == 0) {
        final warehouseName = 'المركز الرئيسي';
        final location = 'صنعاء الحصبة شارع الفاهرة';
        final sql =
            "INSERT INTO ${WarehousesTable.tableName} (${WarehousesTable.id}, ${WarehousesTable.warehouseName}, ${WarehousesTable.location}, ${WarehousesTable.warehouseType}, ${WarehousesTable.parentId}) VALUES (1, '$warehouseName', '$location', '${WarehouseType.branch}', NULL)";
        debugPrint(sql);
        db.execute(sql);
      }
    } catch (e) {
      debugPrint('insert default warehouses failed: $e');
    }
  }

  static void _insertUnits(Database db) {
    try {
      final rsu = db.select(
        'SELECT COUNT(*) AS cnt FROM ${UnitsTable.tableName}',
      );
      final cntu = rsu.isNotEmpty ? (rsu.first['cnt'] as int) : 0;
      if (cntu == 0) {
        final sql1 =
            "INSERT INTO ${UnitsTable.tableName} (${UnitsTable.id}, ${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness}) VALUES (1, 'piece', 'حبة', 1.0, 1.0, 1.0)";
        debugPrint(sql1);
        db.execute(sql1);
        final sql2 =
            "INSERT INTO ${UnitsTable.tableName} (${UnitsTable.id}, ${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness}) VALUES (2, 'square_meter', 'متر مربع', 1.0, 1.0, 1.0)";
        debugPrint(sql2);
        db.execute(sql2);
        final sql3 =
            "INSERT INTO ${UnitsTable.tableName} (${UnitsTable.id}, ${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness}) VALUES (3, 'linear_meter', 'متر', 1.0, 1.0, 1.0)";
        debugPrint(sql3);
        db.execute(sql3);
        db.execute(
          "INSERT INTO ${UnitsTable.tableName} (${UnitsTable.id}, ${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness}) VALUES (4, 'cubit_meter', 'متر مكعب', 1.0, 1.0, 1.0)",
        );
        db.execute(
          "INSERT INTO ${UnitsTable.tableName} (${UnitsTable.id}, ${UnitsTable.unitType}, ${UnitsTable.unitName}, ${UnitsTable.length}, ${UnitsTable.width}, ${UnitsTable.thickness}) VALUES (5, 'weight', 'كيلو', 1.0, 1.0, 1.0)",
        );
      }
    } catch (e) {
      debugPrint('insert default units failed: $e');
    }
  }

  static void _insertExchangePrices(Database db) {
    try {
      final rse = db.select(
        'SELECT COUNT(*) AS cnt FROM ${ExchangePricesTable.tableName}',
      );
      final cnte = rse.isNotEmpty ? (rse.first['cnt'] as int) : 0;
      if (cnte == 0) {
        final currencies = db.select(
          'SELECT ${CurrenciesTable.id} AS id FROM ${CurrenciesTable.tableName}',
        );
        for (final fromRow in currencies) {
          for (final toRow in currencies) {
            final fromId = fromRow['id'];
            final toId = toRow['id'];
            final sql =
                "INSERT INTO ${ExchangePricesTable.tableName} (${ExchangePricesTable.fromCurrencyId}, ${ExchangePricesTable.toCurrencyId}, ${ExchangePricesTable.exchangePrice}) VALUES ('$fromId', '$toId', 1.0)";
            debugPrint(sql);
            db.execute(sql);
          }
        }
      }
    } catch (e) {
      debugPrint('insert default exchange prices failed: $e');
    }
  }

  static void _insertAccountingPeriod(Database db) {
    try {
      final rsp = db.select(
        'SELECT COUNT(*) AS cnt FROM ${AccountingPeriodsTable.tableName}',
      );
      final cntp = rsp.isNotEmpty ? (rsp.first['cnt'] as int) : 0;
      if (cntp == 0) {
        final startDate = DateTime.now().toIso8601String();
        final sql =
            "INSERT INTO ${AccountingPeriodsTable.tableName} "
            "(${AccountingPeriodsTable.balance}, ${AccountingPeriodsTable.currencyId}, ${AccountingPeriodsTable.lastPeriodId}, ${AccountingPeriodsTable.periodName}, ${AccountingPeriodsTable.dateOfStartPeriod}, ${AccountingPeriodsTable.dateOfEndPeriod}, ${AccountingPeriodsTable.inventoryType}) "
            "VALUES (0.0, 'YER', NULL, '2026', '$startDate', NULL, NULL)";
        debugPrint(sql);
        db.execute(sql);
      }
    } catch (e) {
      debugPrint('insert default accounting period failed: $e');
    }
  }

  static void _insertFurnitureTestData(Database db) {
    try {
      // Check if already inserted
      final rs = db.select(
        "SELECT COUNT(*) AS cnt FROM ${CategoriesTable.tableName} WHERE ${CategoriesTable.categoryNumber} LIKE 'FUR-%'",
      );
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt > 0) return; // Already seeded

      debugPrint('Seeding 100 furniture items and accounts...');

      // 1. Insert Main Account
      db.execute('''
        INSERT OR IGNORE INTO ${MainAccountsTable.tableName} (
          ${MainAccountsTable.id}, ${MainAccountsTable.accountNumber}, ${MainAccountsTable.accountName}, 
          ${MainAccountsTable.currencyId}, ${MainAccountsTable.debitBalance}, ${MainAccountsTable.creditBalance}, 
          ${MainAccountsTable.mainAccountType}
        ) VALUES (80, '8000', 'حسابات المفروشات والتجهيزات', 'YER', 0.0, 0.0, 'inventory')
      ''');

      final nowStr = DateTime.now().toIso8601String();

      // 2. Insert Sub Accounts
      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (801, 'صندوق المعرض الفرعي', '8101', 80, 'YER', 0.0, 0.0, 'cash_treasury', '$nowStr')
      ''');

      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (802, 'رأس مال قسم المفروشات', '8102', 80, 'YER', 0.0, 0.0, 'money_head', '$nowStr')
      ''');

      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (803, 'مخزون المفروشات الرئيسي', '8103', 80, 'YER', 0.0, 0.0, 'inventory', '$nowStr')
      ''');

      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (804, 'تكلفة مبيعات المفروشات', '8104', 80, 'YER', 0.0, 0.0, 'cost_of_goods_sold', '$nowStr')
      ''');

      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (805, 'إيرادات مبيعات المفروشات', '8105', 80, 'YER', 0.0, 0.0, 'sales', '$nowStr')
      ''');

      db.execute('''
        INSERT OR IGNORE INTO ${SubAccountsTable.tableName} (
          ${SubAccountsTable.id}, ${SubAccountsTable.accountName}, ${SubAccountsTable.accountNumber}, 
          ${SubAccountsTable.mainAccountId}, ${SubAccountsTable.currencyId}, ${SubAccountsTable.incrementBalance}, 
          ${SubAccountsTable.decrementBalance}, ${SubAccountsTable.subAccountType}, ${SubAccountsTable.createdAt}
        ) VALUES (806, 'مصاريف مبيعات المفروشات', '8106', 80, 'YER', 0.0, 0.0, 'expenses', '$nowStr')
      ''');

      // 3. Generate 100 unique categories programmatically
      final types = [
        "كنبة",
        "كرسي",
        "طاولة",
        "سرير",
        "دولاب",
        "مكتب",
        "مكتبة",
        "مغسلة",
        "خزانة",
        "ستارة",
      ];
      final materials = [
        "خشب زان",
        "خشب بلوط",
        "معدني مودرن",
        "جلد طبيعي",
        "مخمل ناعم",
        "ألمنيوم",
        "زجاجي",
      ];
      final styles = [
        "كلاسيك",
        "نيو كلاسيك",
        "مودرن",
        "تركي راقي",
        "إيطالي فاخر",
        "أمريكي مريح",
      ];
      final colors = [
        "بني محروق",
        "بيج فاتح",
        "رمادي داكن",
        "ذهبي ملكي",
        "أبيض مطفي",
        "كحلي فاخر",
      ];

      final List<String> uniqueNames = [];
      var idx = 0;
      for (final t in types) {
        for (final m in materials) {
          for (final s in styles) {
            for (final c in colors) {
              final name = '$t $m $s $c';
              uniqueNames.add(name);
              idx++;
              if (idx >= 100) break;
            }
            if (idx >= 100) break;
          }
          if (idx >= 100) break;
        }
        if (idx >= 100) break;
      }

      // Get Accounting Period ID
      final periodRow = db.select(
        'SELECT ${AccountingPeriodsTable.id} FROM ${AccountingPeriodsTable.tableName} LIMIT 1',
      );
      final periodId = periodRow.isNotEmpty
          ? (periodRow.first[AccountingPeriodsTable.id] as int)
          : 1;

      // Insert categories, inventories, and opening quantities
      for (var i = 0; i < 100; i++) {
        final catId = 1000 + i;
        final invId = 1000 + i;
        final catNum = 'FUR-${catId.toString().padLeft(4, "0")}';
        final catName = uniqueNames[i];

        // Insert Category
        db.execute('''
          INSERT INTO ${CategoriesTable.tableName} (
            ${CategoriesTable.id}, ${CategoriesTable.categoryType}, ${CategoriesTable.categoryName}, 
            ${CategoriesTable.categoryNumber}, ${CategoriesTable.categoryUnitId}, ${CategoriesTable.pricingUnitId}, 
            ${CategoriesTable.inventoryUnitId}
          ) VALUES ($catId, 'material', '$catName', '$catNum', 1, 1, 1)
        ''');

        // Insert Inventory (triggers automatic journal entry and items)
        final initialCost = 12000.0;
        final initialQty = 10.0;
        db.execute('''
          INSERT INTO ${InventoriesTable.tableName} (
            ${InventoriesTable.id}, ${InventoriesTable.categoryId}, ${InventoriesTable.storeId},
            ${InventoriesTable.propertyAccountId}, ${InventoriesTable.revenueAccountId}, ${InventoriesTable.expenseAccountId},
            ${InventoriesTable.incomeStockId}, ${InventoriesTable.outcomeStockId}, ${InventoriesTable.costTotal},
            ${InventoriesTable.countUnits}, ${InventoriesTable.userId}
          ) VALUES ($invId, $catId, 1, 802, 805, 806, 803, 804, $initialCost, $initialQty, 1)
        ''');

        // Insert Opening Quantity
        db.execute('''
          INSERT INTO ${OpeningQuantitiesTable.tableName} (
            ${OpeningQuantitiesTable.inventoryId}, ${OpeningQuantitiesTable.countUnits}, ${OpeningQuantitiesTable.createdAt},
            ${OpeningQuantitiesTable.costTotal}, ${OpeningQuantitiesTable.periodId}, ${OpeningQuantitiesTable.currencyId}
          ) VALUES ($invId, $initialQty, '$nowStr', $initialCost, $periodId, 'YER')
        ''');
      }

      debugPrint('Seeded 100 furniture items and accounts successfully.');
    } catch (e, stack) {
      debugPrint('Failed to seed furniture test data: $e\n$stack');
    }
  }
}
