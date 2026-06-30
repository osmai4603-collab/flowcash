import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/features/accounts/data/models/main_account_model.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_model.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/categories/data/datasources/category_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/models/category_model.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/currencies/data/models/exchange_price_model.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/data/datasources/opening_quantity_data_source.dart';
import 'package:flowcash/features/inventory/data/models/inventory_model.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/data/models/opening_quantity_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';

final class OpeningQuantityLocalDataSourceImpl
    implements OpeningQuantityDataSource {
  final SqliteService _db;
  final Map<String, dynamic> Function(JournalEntryEntity) journalEntryToMap;
  final Map<String, dynamic> Function(JournalItemEntity) journalItemToMap;

  const OpeningQuantityLocalDataSourceImpl(
    this._db,
    this.journalEntryToMap,
    this.journalItemToMap,
  );

  @override
  Future<List<OpeningQuantityEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: OpeningQuantitiesTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${OpeningQuantitiesTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<OpeningQuantityEntity?> getById(int id) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where: '${OpeningQuantitiesTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<OpeningQuantityEntity> insert(OpeningQuantityEntity entity) async {
    return await _db.transaction(() async {
      // 1. Get associated inventory details
      final inventoryEntity = await _getInventory(entity.inventoryId);
      if (inventoryEntity == null) {
        throw Exception('Inventory not found for ID: ${entity.inventoryId}');
      }

      final category = await _getCategory(inventoryEntity.categoryId);
      if (category == null) {
        throw Exception('Category Can Not Be NULL');
      }

      final categoryUnit = await _getUnit(category.categoryUnitId);
      if (categoryUnit == null) {
        throw Exception('Category Unit Can Not Be NULL');
      }

      // 2. Insert journal entry
      var journalEntry = JournalEntryEntity.fromOpeningQuantity(
        openingQuantity: entity,
        warehouseId: inventoryEntity.storeId,
        userId: inventoryEntity.userId,
        categoryName: category.categoryName,
      );
      journalEntry = await _insertJournalEntry(journalEntry);

      final propertyAccount = await _getSubaccount(
        inventoryEntity.propertyAccountId,
      );
      if (propertyAccount == null) {
        throw Exception('Property Account Can Not Be NULL');
      }

      final propertyMainAccount = await _getMainAccount(
        propertyAccount.mainAccountId,
      );
      if (propertyMainAccount == null) {
        throw Exception('Property Main Account Can Not Be NULL');
      }

      final incomeAccount = await _getSubaccount(inventoryEntity.incomeStockId);
      if (incomeAccount == null) {
        throw Exception('Income Account Can Not Be NULL');
      }

      final incomeMainAccount = await _getMainAccount(
        incomeAccount.mainAccountId,
      );
      if (incomeMainAccount == null) {
        throw Exception('Income Account Can Not Be NULL');
      }

      // 3. Insert journal items
      var incomeItem = JournalItemEntity.fromOpeningQuantity(
        openingQuantity: entity,
        accountId: inventoryEntity.incomeStockId,

        journalEntryId: journalEntry.id,
        lineDescription:
            'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)} ${categoryUnit.unitName} ${category.categoryName}',
        exPrice: await _getExPrice(entity.currencyId, incomeAccount.currencyId),
        expriceMain: await _getExPrice(
          entity.currencyId,
          incomeMainAccount.currencyId,
        ),
      );
      incomeItem = await _insertJournalItem(incomeItem);

      // Credit (Decrement)
      var propertyItem = JournalItemEntity.fromOpeningQuantity(
        openingQuantity: entity,
        lineDescription:
            'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)} ${categoryUnit.unitName} ${category.categoryName}',
        accountId: propertyAccount.id,
        journalEntryId: journalEntry.id,
        exPrice: await _getExPrice(
          entity.currencyId,
          propertyAccount.currencyId,
        ),
        expriceMain: await _getExPrice(
          entity.currencyId,
          propertyMainAccount.currencyId,
        ),
      );
      propertyItem = await _insertJournalItem(propertyItem);

      // 4. Insert opening quantity with journal entry ID
      final entityToInsert = entity.copyWith(journalEntryId: journalEntry.id);
      final entityId = await _db.insert(
        table: OpeningQuantitiesTable().tableName,
        data: _sanitizeInsertData(
          toMap(entityToInsert),
          OpeningQuantitiesTable().id,
        ),
      );
      if (entityId < 0) {
        throw Exception('Failed to insert opening quantity');
      }

      // 5. Update associated inventory countUnits and costTotal
      final updatedCountUnits = inventoryEntity.countUnits + entity.countUnits;
      final updatedCostTotal = inventoryEntity.costTotal + entity.costTotal;
      await _db.update(
        table: InventoriesTable().tableName,
        data: {
          InventoriesTable().countUnits: updatedCountUnits,
          InventoriesTable().costTotal: updatedCostTotal,
        },
        where: {InventoriesTable().id: entity.inventoryId},
      );

      return entityToInsert.copyWith(id: entityId);
    });
  }

  @override
  Future<OpeningQuantityEntity> update(OpeningQuantityEntity entity) async {
    return await _db.transaction(() async {
      final oldEntity = await getById(entity.id);

      // Get associated inventory details

      final inventoryEntity = await _getInventory(entity.inventoryId);
      if (inventoryEntity == null) {
        throw Exception('Inventory not found for ID: ${entity.inventoryId}');
      }

      final category = await _getCategory(inventoryEntity.categoryId);
      if (category == null) {
        throw Exception('Category Can Not Be NULL');
      }

      final categoryUnit = await _getUnit(category.categoryUnitId);
      if (categoryUnit == null) {
        throw Exception('Category Unit Can Not Be NULL');
      }

      // 2. Insert journal entry
      var journalEntry = JournalEntryEntity.fromOpeningQuantity(
        openingQuantity: entity,
        warehouseId: inventoryEntity.storeId,
        userId: inventoryEntity.userId,
        categoryName: category.categoryName,
      );
      journalEntry = await _insertJournalEntry(journalEntry);

      final propertyAccount = await _getSubaccount(
        inventoryEntity.propertyAccountId,
      );
      if (propertyAccount == null) {
        throw Exception('Property Account Can Not Be NULL');
      }

      final propertyMainAccount = await _getMainAccount(
        propertyAccount.mainAccountId,
      );
      if (propertyMainAccount == null) {
        throw Exception('Property Main Account Can Not Be NULL');
      }

      final incomeAccount = await _getSubaccount(inventoryEntity.incomeStockId);
      if (incomeAccount == null) {
        throw Exception('Income Account Can Not Be NULL');
      }

      final incomeMainAccount = await _getMainAccount(
        incomeAccount.mainAccountId,
      );
      if (incomeMainAccount == null) {
        throw Exception('Income Account Can Not Be NULL');
      }

      int? journalEntryId = entity.journalEntryId;
      if (journalEntryId == null && oldEntity != null) {
        journalEntryId = oldEntity.journalEntryId;
      }

      if (journalEntryId == null || journalEntryId <= 0) {
        // Insert new journal entry if none existed
        var journalEntry = JournalEntryEntity.fromOpeningQuantity(
          openingQuantity: entity,
          warehouseId: inventoryEntity.storeId,
          userId: inventoryEntity.userId,
          categoryName: category.categoryName,
        );
        journalEntry = await _insertJournalEntry(journalEntry);
        if (journalEntry.id <= 0) {
          throw Exception('Failed to insert journal entry during update');
        }
        journalEntryId = journalEntry.id;

        // Insert journal items

        var incomeItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          accountId: inventoryEntity.incomeStockId,

          journalEntryId: journalEntry.id,
          lineDescription:
              'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)}${categoryUnit.getCategoryName()} ${category.categoryName}',
          exPrice: await _getExPrice(
            entity.currencyId,
            incomeAccount.currencyId,
          ),
          expriceMain: await _getExPrice(
            entity.currencyId,
            incomeMainAccount.currencyId,
          ),
        );
        incomeItem = await _insertJournalItem(incomeItem);

        // Credit (Decrement)
        var propertyItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          lineDescription:
              'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)}${categoryUnit.getCategoryName()} ${category.categoryName}',
          accountId: propertyAccount.id,
          journalEntryId: journalEntry.id,
          exPrice: await _getExPrice(
            entity.currencyId,
            propertyAccount.currencyId,
          ),
          expriceMain: await _getExPrice(
            entity.currencyId,
            propertyMainAccount.currencyId,
          ),
        );
        propertyItem = await _insertJournalItem(propertyItem);
      } else {
        // Update existing journal entry
        final journalEntry = JournalEntryEntity.fromOpeningQuantity(
          openingQuantity: entity,
          warehouseId: inventoryEntity.storeId,
          userId: inventoryEntity.userId,
          categoryName: category.categoryName,
        ).copyWith(id: journalEntryId);

        await _db.update(
          table: JournalEntriesTable().tableName,
          data: journalEntryToMap(journalEntry),
          where: {JournalEntriesTable().id: journalEntryId},
        );

        // Update increment journal item
        final incomeItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          accountId: inventoryEntity.incomeStockId,

          journalEntryId: journalEntry.id,
          lineDescription:
              'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)}${categoryUnit.getCategoryName()} ${category.categoryName}',
          exPrice: await _getExPrice(
            entity.currencyId,
            incomeAccount.currencyId,
          ),
          expriceMain: await _getExPrice(
            entity.currencyId,
            incomeMainAccount.currencyId,
          ),
        );
        await _db.update(
          table: JournalItemsTable().tableName,
          data: journalItemToMap(incomeItem),
          where: {
            JournalItemsTable().entryId: journalEntryId,
            JournalItemsTable().journalStatus: JournalStatus.increment.name,
          },
        );

        // Update decrement journal item
        final propertyItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          lineDescription:
              'كيمة افتتاحية: ${AppMoneyFormatter.formatDouble(entity.countUnits)}${categoryUnit.getCategoryName()} ${category.categoryName}',
          accountId: propertyAccount.id,
          journalEntryId: journalEntry.id,
          exPrice: await _getExPrice(
            entity.currencyId,
            propertyAccount.currencyId,
          ),
          expriceMain: await _getExPrice(
            entity.currencyId,
            propertyMainAccount.currencyId,
          ),
        );
        await _db.update(
          table: JournalItemsTable().tableName,
          data: journalItemToMap(propertyItem),
          where: {
            JournalItemsTable().entryId: journalEntryId,
            JournalItemsTable().journalStatus: JournalStatus.decrement.name,
          },
        );
      }

      if (oldEntity != null) {
        if (oldEntity.inventoryId == entity.inventoryId) {
          final diffCountUnits = entity.countUnits - oldEntity.countUnits;
          final diffCostTotal = entity.costTotal - oldEntity.costTotal;
          final updatedCountUnits = inventoryEntity.countUnits + diffCountUnits;
          final updatedCostTotal = inventoryEntity.costTotal + diffCostTotal;
          await _db.update(
            table: InventoriesTable().tableName,
            data: {
              InventoriesTable().countUnits: updatedCountUnits,
              InventoriesTable().costTotal: updatedCostTotal,
            },
            where: {InventoriesTable().id: entity.inventoryId},
          );
        } else {
          final oldInventory = await _getInventory(oldEntity.inventoryId);
          if (oldInventory != null) {
            await _db.update(
              table: InventoriesTable().tableName,
              data: {
                InventoriesTable().countUnits:
                    oldInventory.countUnits - oldEntity.countUnits,
                InventoriesTable().costTotal:
                    oldInventory.costTotal - oldEntity.costTotal,
              },
              where: {InventoriesTable().id: oldEntity.inventoryId},
            );
          }
          final updatedCountUnits =
              inventoryEntity.countUnits + entity.countUnits;
          final updatedCostTotal = inventoryEntity.costTotal + entity.costTotal;
          await _db.update(
            table: InventoriesTable().tableName,
            data: {
              InventoriesTable().countUnits: updatedCountUnits,
              InventoriesTable().costTotal: updatedCostTotal,
            },
            where: {InventoriesTable().id: entity.inventoryId},
          );
        }
      } else {
        final updatedCountUnits =
            inventoryEntity.countUnits + entity.countUnits;
        final updatedCostTotal = inventoryEntity.costTotal + entity.costTotal;
        await _db.update(
          table: InventoriesTable().tableName,
          data: {
            InventoriesTable().countUnits: updatedCountUnits,
            InventoriesTable().costTotal: updatedCostTotal,
          },
          where: {InventoriesTable().id: entity.inventoryId},
        );
      }

      final entityToUpdate = entity.copyWith(journalEntryId: journalEntryId);
      await _db.update(
        table: OpeningQuantitiesTable().tableName,
        data: toMap(entityToUpdate),
        where: {OpeningQuantitiesTable().id: entity.id},
      );
      return entityToUpdate;
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      final oldEntity = await getById(id);
      if (oldEntity != null) {
        final inventoryEntity = await _getInventory(oldEntity.inventoryId);
        if (inventoryEntity != null) {
          final updatedCountUnits =
              inventoryEntity.countUnits - oldEntity.countUnits;
          final updatedCostTotal =
              inventoryEntity.costTotal - oldEntity.costTotal;
          await _db.update(
            table: InventoriesTable().tableName,
            data: {
              InventoriesTable().countUnits: updatedCountUnits,
              InventoriesTable().costTotal: updatedCostTotal,
            },
            where: {InventoriesTable().id: oldEntity.inventoryId},
          );
        }

        final journalEntryId = oldEntity.journalEntryId;
        if (journalEntryId != null && journalEntryId > 0) {
          // Delete journal items first
          await _db.deleteWhere(
            table: JournalItemsTable().tableName,
            where: {JournalItemsTable().entryId: journalEntryId},
          );

          // Delete journal entry
          await _db.deleteWhere(
            table: JournalEntriesTable().tableName,
            where: {JournalEntriesTable().id: journalEntryId},
          );
        }
      }

      await _db.deleteWhere(
        table: OpeningQuantitiesTable().tableName,
        where: {OpeningQuantitiesTable().id: id},
      );
      return true;
    });
  }

  @override
  OpeningQuantityEntity fromMap(Map<String, dynamic> map) {
    return OpeningQuantityModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(OpeningQuantityEntity entity) {
    if (entity is OpeningQuantityModel) {
      return entity.toMap();
    }
    return OpeningQuantityModel(
      id: entity.id,
      inventoryId: entity.inventoryId,
      countUnits: entity.countUnits,
      createdAt: entity.createdAt,
      costTotal: entity.costTotal,
      periodId: entity.periodId,
      currencyId: entity.currencyId,
      journalEntryId: entity.journalEntryId,
    ).toMap();
  }

  @override
  Future<OpeningQuantityEntity?> getOpeningQuantity({
    required int inventoryId,
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where: '${OpeningQuantitiesTable().inventoryId} = ?',
      whereArgs: [inventoryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<double> getSumUnitsByInventory(
    int inventoryId, {
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where: '${OpeningQuantitiesTable().inventoryId} = ?',
      whereArgs: [inventoryId],
    );

    return rows.fold<double>(0.0, (sum, row) {
      return sum +
          ((row[OpeningQuantitiesTable().countUnits] as num).toDouble());
    });
  }

  @override
  Future<List<OpeningQuantityEntity>> whereCommodity(
    InventoryEntity commodity, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where: '${OpeningQuantitiesTable().inventoryId} = ?',
      whereArgs: [commodity.id],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<OpeningQuantityEntity>> whereStore(
    int storeId, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable().tableName,
      where:
          '${OpeningQuantitiesTable().inventoryId} IN (SELECT ${InventoriesTable().id} FROM ${InventoriesTable().tableName} WHERE ${InventoriesTable().storeId} = ?)',
      whereArgs: [storeId],
    );
    return rows.map(fromMap).toList();
  }

  Map<String, dynamic> _sanitizeInsertData(
    Map<String, dynamic> data,
    String idKey,
  ) {
    if (data[idKey] is int && (data[idKey] as int) <= 0) {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized.remove(idKey);
      return sanitized;
    }
    return data;
  }

  Future<SubAccountEntity?> _getSubaccount(int accountId) async {
    final result = await _db.query(
      table: SubAccountsTable().tableName,
      where: '${SubAccountsTable().id} = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return SubAccountModel.fromMap(result.first);
  }

  Future<MainAccountModel?> _getMainAccount(int accountId) async {
    final result = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().id} = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return MainAccountModel.fromMap(result.first);
  }

  Future<CategoryEntity?> _getCategory(int categoryId) async {
    final result = await _db.query(
      table: CategoriesTable().tableName,
      where: '${CategoriesTable().id} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromMap(result.first);
  }

  Future<InventoryEntity?> _getInventory(int inventoryId) async {
    final result = await _db.query(
      table: InventoriesTable().tableName,
      where: '${InventoriesTable().id} = ?',
      whereArgs: [inventoryId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return InventoryModel.fromMap(result.first);
  }

  Future<UnitEntity?> _getUnit(int categoryId) async {
    final result = await _db.query(
      table: UnitsTable().tableName,
      where: '${UnitsTable().id} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UnitModel.fromMap(result.first);
  }

  Future<double> _getExPrice(String fromCurrencyId, String toCurrencyId) async {
    final result = await _db.query(
      table: ExchangePricesTable().tableName,
      where:
          '${ExchangePricesTable().fromCurrencyId} = ? AND ${ExchangePricesTable().toCurrencyId} = ?',
      whereArgs: [fromCurrencyId, toCurrencyId],
      limit: 1,
    );
    if (result.isEmpty) return 1.0;
    return ExchangePriceModel.fromMap(result.first).price;
  }

  Future<JournalEntryEntity> _insertJournalEntry(
    JournalEntryEntity entity,
  ) async {
    final result = await _db.insert(
      table: JournalEntriesTable().tableName,
      data: journalEntryToMap(entity),
    );
    if (result <= 0) {
      throw Exception('Error on Insert Journal Entry');
    }
    return entity.copyWith(id: result);
  }

  Future<JournalItemEntity> _insertJournalItem(JournalItemEntity entity) async {
    final result = await _db.insert(
      table: JournalItemsTable().tableName,
      data: journalItemToMap(entity),
    );
    if (result <= 0) {
      throw Exception('Error on Insert Journal Item');
    }
    return entity.copyWith(id: result);
  }
}
