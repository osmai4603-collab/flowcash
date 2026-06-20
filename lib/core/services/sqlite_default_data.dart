import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/enums/user_type_enum.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/features/auth/data/models/program_user_model.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/features/categories/domain/entities/measurable_unit.dart';
import 'package:flowcash/features/currencies/data/models/currency_model.dart';
import 'package:flowcash/features/currencies/data/models/exchange_price_model.dart';
import 'package:flowcash/features/inventory/data/models/warehouse_model.dart';
import 'package:flowcash/features/settings/data/models/value_counter_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/inventory/data/models/opening_quantity_model.dart';
import 'package:flowcash/features/inventory/data/models/inventory_model.dart';
import 'package:flowcash/features/categories/data/models/category_model.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_model.dart';
import 'package:flowcash/features/accounts/data/models/main_account_model.dart';

final class DefaultDataInserter {
  const DefaultDataInserter._();

  static const _currencies = [
    CurrencyModel(id: 'YER', name: 'ريال يمني', symbol: 'ر.ي', isDefault: true),
    CurrencyModel(
      id: 'SAR',
      name: 'ريال سعودي',
      symbol: 'ر.س',
      isDefault: false,
    ),
    CurrencyModel(
      id: 'USD',
      name: 'دولار امريكي',
      symbol: '\$',
      isDefault: false,
    ),
  ];

  static const _warehouses = [
    WarehouseModel(
      id: 1,
      warehouseName: 'المركز الرئيسي',
      location: 'صنعاء الحصبة شارع الفاهرة',
      warehouseType: WarehouseType.branch,
    ),
  ];

  static const _programUsers = [
    ProgramUserModel(
      id: 1,
      userName: 'admin',
      password: 'admin',
      userType: UserType.admin,
      warehouseId: 1,
    ),
  ];

  static const _units = [
    UnitModel(
      id: 1,
      unitName: 'حبة',
      unitType: UnitType.piece,
      measurement: PieceMeasurableUnit(count: 0.0),
    ),
    UnitModel(
      id: 2,
      unitName: 'متر طولي',
      unitType: UnitType.linearMeter,
      measurement: LinearMeasurableUnit(0.0),
    ),
    UnitModel(
      id: 3,
      unitName: 'متر مربع',
      unitType: UnitType.squareMeter,
      measurement: AreaMeasurableUnit(length: 0.0, width: 0.0),
    ),
    UnitModel(
      id: 4,
      unitName: 'متر مكعب',
      unitType: UnitType.cubitMeter,
      measurement: VolumeMeasurableUnit(
        length: 0.0,
        width: 0.0,
        thickness: 0.0,
      ),
    ),
    UnitModel(
      id: 5,
      unitName: 'كيلو جرام',
      unitType: UnitType.weight,
      measurement: WeightMeasurableUnit(0.0),
    ),
  ];

  static void insertDefaults(Database db) {
    _insertCurrencies(db);
    _insertWarehouses(db);
    _insertProgramUsers(db);
    _insertUnits(db);
    _insertExchangePrices(db);
    _insertAccountingPeriod(db);
    _insertValuesCounterDefaults(db);
    _insertDefaultValues(db);
    if (kDebugMode) _insertFurnitureTestData(db);
  }

  static void _insertModel(
    Database db,
    String tableName,
    Map<String, dynamic> data,
  ) {
    final keys = data.keys.join(', ');
    final placeholders = data.keys.map((_) => '?').join(', ');
    final sql = 'INSERT INTO $tableName ($keys) VALUES ($placeholders)';
    debugPrint(sql);
    db.execute(sql, data.values.toList());
  }

  static void _insertDefaultValues(Database db) {
    try {
      final rs = db.select(
        'SELECT COUNT(*) AS cnt FROM ${ValuesTable.tableName}',
      );
      final cnt = rs.isNotEmpty ? (rs.first['cnt'] as int) : 0;
      if (cnt == 0) {
        for (final vt in ValueType.values) {
          final data = {
            ValuesTable.value: vt.defaultValue,
            ValuesTable.valueType: vt.name,
          };
          _insertModel(db, ValuesTable.tableName, data);
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
        final counter = ValueCounterModel(
          id: 1,
          counterType: ValueCounterType.categoryNumber,
          count: 1001,
          counterMax: 99999,
          incrementValue: 1,
          formatValue: '0000',
        );
        _insertModel(db, ValuesCounterTable.tableName, counter.toMap());
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
        for (final user in _programUsers) {
          _insertModel(db, ProgramUsersTable.tableName, user.toMap());
        }
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
        for (final currency in _currencies) {
          _insertModel(db, CurrenciesTable.tableName, currency.toMap());
        }
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
        for (final warehouse in _warehouses) {
          _insertModel(db, WarehousesTable.tableName, warehouse.toMap());
        }
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
        for (final unit in _units) {
          _insertModel(db, UnitsTable.tableName, unit.toMap());
        }
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
            final fromId = fromRow['id'] as String;
            final toId = toRow['id'] as String;
            final price = ExchangePriceModel(
              id: 0,
              fromCurrencyId: fromId,
              toCurrencyId: toId,
              price: 1.0,
            );
            _insertModel(db, ExchangePricesTable.tableName, price.toMap());
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
        final data = {
          AccountingPeriodsTable.balance: 0.0,
          AccountingPeriodsTable.currencyId: 'YER',
          AccountingPeriodsTable.lastPeriodId: null,
          AccountingPeriodsTable.periodName: '2026',
          AccountingPeriodsTable.dateOfStartPeriod: DateTime.now()
              .toIso8601String(),
          AccountingPeriodsTable.dateOfEndPeriod: null,
          AccountingPeriodsTable.inventoryType: null,
        };
        _insertModel(db, AccountingPeriodsTable.tableName, data);
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
      final mainAccount = MainAccountModel(
        id: 80,
        accountNumber: '8000',
        accountName: 'حسابات المفروشات والتجهيزات',
        currencyId: 'YER',
        debitBalance: 0.0,
        creditBalance: 0.0,
        mainAccountType: MainAccountType.of('inventory'),
      );
      _insertModel(db, MainAccountsTable.tableName, mainAccount.toMap());

      final now = DateTime.now();

      // 2. Insert Sub Accounts
      final subAccounts = [
        SubAccountModel(
          id: 801,
          accountName: 'صندوق المعرض الفرعي',
          accountNumber: '8101',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('cash_treasury'),
          createdAt: now,
        ),
        SubAccountModel(
          id: 802,
          accountName: 'رأس مال قسم المفروشات',
          accountNumber: '8102',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('money_head'),
          createdAt: now,
        ),
        SubAccountModel(
          id: 803,
          accountName: 'مخزون المفروشات الرئيسي',
          accountNumber: '8103',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('inventory'),
          createdAt: now,
        ),
        SubAccountModel(
          id: 804,
          accountName: 'تكلفة مبيعات المفروشات',
          accountNumber: '8104',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('cost_of_goods_sold'),
          createdAt: now,
        ),
        SubAccountModel(
          id: 805,
          accountName: 'إيرادات مبيعات المفروشات',
          accountNumber: '8105',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('sales'),
          createdAt: now,
        ),
        SubAccountModel(
          id: 806,
          accountName: 'مصاريف مبيعات المفروشات',
          accountNumber: '8106',
          mainAccountId: 80,
          currencyId: 'YER',
          incrementBalance: 0.0,
          decrementBalance: 0.0,
          subAccountType: SubAccountType.of('expenses'),
          createdAt: now,
        ),
      ];

      for (final sub in subAccounts) {
        _insertModel(db, SubAccountsTable.tableName, sub.toMap());
      }

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
        final initialCost = 12000.0;
        final initialQty = 10.0;

        final category = CategoryModel(
          id: catId,
          categoryName: catName,
          categoryNumber: catNum,
          barcode: '',
          categoryType: CategoryDefineType.commodities,
          categoryUnitId: 1,
          pricingUnitId: 1,
          inventoryUnitId: 1,
        );
        _insertModel(db, CategoriesTable.tableName, category.toMap());

        final inventory = InventoryModel(
          id: invId,
          categoryId: catId,
          storeId: 1,
          propertyAccountId: 802,
          revenueAccountId: 805,
          expenseAccountId: 806,
          incomeStockId: 803,
          outcomeStockId: 804,
          inventoryName: catName,
          costTotal: initialCost,
          countUnits: initialQty,
          userId: 1,
        );
        _insertModel(db, InventoriesTable.tableName, inventory.toMap());

        final openingQuantity = OpeningQuantityModel(
          id: 0,
          inventoryId: invId,
          countUnits: initialQty,
          createdAt: now,
          costTotal: initialCost,
          periodId: periodId,
          currencyId: 'YER',
        );

        final oqMap = openingQuantity.toMap();
        oqMap.remove('id'); // ID is likely AUTOINCREMENT, so remove it if 0
        _insertModel(db, OpeningQuantitiesTable.tableName, oqMap);
      }

      debugPrint('Seeded 100 furniture items and accounts successfully.');
    } catch (e, stack) {
      debugPrint('Failed to seed furniture test data: $e\n$stack');
    }
  }
}
