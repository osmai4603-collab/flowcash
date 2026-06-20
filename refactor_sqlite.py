import os

file_path = "lib/core/services/sqlite_default_data.dart"

with open(file_path, "r") as f:
    content = f.read()

# Add imports if they don't exist
imports = """
import 'package:flowcash/features/accounts/data/models/main_account_model.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_model.dart';
import 'package:flowcash/features/categories/data/models/category_model.dart';
import 'package:flowcash/features/inventory/data/models/inventory_model.dart';
import 'package:flowcash/features/inventory/data/models/opening_quantity_model.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
"""

for imp in imports.strip().split('\n'):
    if imp not in content:
        content = content.replace("import 'package:sqlite3/sqlite3.dart';", f"import 'package:sqlite3/sqlite3.dart';\n{imp}")

# Now replace the db.execute lines
# We'll locate "      // 1. Insert Main Account"
start_marker = "      // 1. Insert Main Account"
end_marker = "      debugPrint('Seeded 100 furniture items and accounts successfully.');"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_code = """      // 1. Insert Main Account
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
        "كنبة", "كرسي", "طاولة", "سرير", "دولاب",
        "مكتب", "مكتبة", "مغسلة", "خزانة", "ستارة",
      ];
      final materials = [
        "خشب زان", "خشب بلوط", "معدني مودرن", "جلد طبيعي",
        "مخمل ناعم", "ألمنيوم", "زجاجي",
      ];
      final styles = [
        "كلاسيك", "نيو كلاسيك", "مودرن", "تركي راقي",
        "إيطالي فاخر", "أمريكي مريح",
      ];
      final colors = [
        "بني محروق", "بيج فاتح", "رمادي داكن", "ذهبي ملكي",
        "أبيض مطفي", "كحلي فاخر",
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

"""
    content = content[:start_idx] + new_code + content[end_idx:]

with open(file_path, "w") as f:
    f.write(content)
