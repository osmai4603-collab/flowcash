import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/tables/values_table.dart';
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
  }

  static void _insertDefaultValues(Database db) {
    try {
      final rs = db.select('SELECT COUNT(*) AS cnt FROM ${ValuesTable.tableName}');
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt == 0) {
        for (final vt in ValueType.values) {
          final v = vt.defaultValue.replaceAll("'", "''");
          final sql = "INSERT INTO ${ValuesTable.tableName} (${ValuesTable.value}, ${ValuesTable.valueType}) VALUES ('$v', '${vt.name}')";
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
            "${CurrenciesTable.id}, ${CurrenciesTable.currencyName}, ${CurrenciesTable.symbol}, ${CurrenciesTable.fullSymbol}, ${CurrenciesTable.country}, ${CurrenciesTable.selected}";
        final sql =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('YER', 'يمني', 'ر.ي', 'ريال يمني', 'اليمن', 1)";
        debugPrint('Executing query: $sql');
        db.execute(sql);

        final sql2 =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('SAR', 'سعودي', 'ر.س', 'ريال سعودي', 'السعودية', 0)";
        debugPrint(sql2);
        db.execute(sql2);

        final sql3 =
            "INSERT INTO ${CurrenciesTable.tableName} ($field) VALUES ('USD', 'دولار', '\$', 'دولار امريكي', 'الولايات المتحدة الامريكية', 0)";
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
                "INSERT INTO ${ExchangePricesTable.tableName} (${ExchangePricesTable.fromCurrencyId}, ${ExchangePricesTable.toCurrencyId}, ${ExchangePricesTable.exchangePrice}) VALUES ($fromId, $toId, 1.0)";
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
}
