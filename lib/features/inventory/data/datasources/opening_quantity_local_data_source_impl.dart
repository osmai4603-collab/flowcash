import 'package:flowcash/features/inventory/data/datasources/opening_quantity_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/data/models/opening_quantity_model.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
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
      final rows = await _db.query(table: OpeningQuantitiesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${OpeningQuantitiesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: OpeningQuantitiesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<OpeningQuantityEntity?> getById(int id) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable.tableName,
      where: '${OpeningQuantitiesTable.id} = ?',
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
      final inventoryRows = await _db.query(
        table: InventoriesTable.tableName,
        where: '${InventoriesTable.id} = ?',
        whereArgs: [entity.inventoryId],
        limit: 1,
      );
      if (inventoryRows.isEmpty) {
        throw Exception('Inventory not found for ID: ${entity.inventoryId}');
      }
      final inventoryMap = inventoryRows.first;
      final inventoryEntity = InventoryItemEntity(
        id: inventoryMap[InventoriesTable.id] as int,
        categoryId: inventoryMap[InventoriesTable.categoryId] as int,
        storeId: inventoryMap[InventoriesTable.storeId] as int,
        propertyAccountId:
            (inventoryMap[InventoriesTable.propertyAccountId] ?? 0) as int,
        revenueAccountId:
            inventoryMap[InventoriesTable.revenueAccountId] as int,
        expenseAccountId:
            inventoryMap[InventoriesTable.expenseAccountId] as int,
        incomeStockId: inventoryMap[InventoriesTable.incomeStockId] as int,
        outcomeStockId: inventoryMap[InventoriesTable.outcomeStockId] as int,
        inventoryName: '',
        costTotal: ((inventoryMap[InventoriesTable.costTotal] ?? 0) as num)
            .toDouble(),
        countUnits: ((inventoryMap[InventoriesTable.countUnits] ?? 0) as num)
            .toDouble(),
        userId: (inventoryMap[InventoriesTable.userId] ?? 1) as int,
      );

      // 2. Insert journal entry
      final journalEntry = JournalEntryEntity.fromOpeningQuantity(
        openingQuantity: entity,
        warehouseId: inventoryEntity.storeId,
        userId: inventoryEntity.userId,
      );
      final journalEntryId = await _db.insert(
        table: JournalEntriesTable.tableName,
        data: journalEntryToMap(journalEntry),
      );

      if (journalEntryId <= 0) {
        throw Exception('Failed to insert journal entry for opening quantity');
      }

      // 3. Insert journal items
      // Debit (Increment)
      final incomeItem = JournalItemEntity.fromOpeningQuantity(
        openingQuantity: entity,
        inventory: inventoryEntity,
        journalEntryId: journalEntryId,
        journalStatus: JournalStatus.increment,
      );
      final incomeItemId = await _db.insert(
        table: JournalItemsTable.tableName,
        data: journalItemToMap(incomeItem),
      );
      if (incomeItemId <= 0) {
        throw Exception('Failed to insert debit journal item');
      }

      // Credit (Decrement)
      final propertyItem = JournalItemEntity.fromOpeningQuantity(
        openingQuantity: entity,
        inventory: inventoryEntity,
        journalEntryId: journalEntryId,
        journalStatus: JournalStatus.decrement,
      );
      final propertyItemId = await _db.insert(
        table: JournalItemsTable.tableName,
        data: journalItemToMap(propertyItem),
      );
      if (propertyItemId <= 0) {
        throw Exception('Failed to insert credit journal item');
      }

      // 4. Insert opening quantity with journal entry ID
      final entityToInsert = entity.copyWith(journalEntryId: journalEntryId);
      final entityId = await _db.insert(
        table: OpeningQuantitiesTable.tableName,
        data: _sanitizeInsertData(
          toMap(entityToInsert),
          OpeningQuantitiesTable.id,
        ),
      );
      if (entityId < 0) {
        throw Exception('Failed to insert opening quantity');
      }
      return entityToInsert.copyWith(id: entityId);
    });
  }

  @override
  Future<OpeningQuantityEntity> update(OpeningQuantityEntity entity) async {
    return await _db.transaction(() async {
      final oldEntity = await getById(entity.id);

      // Get associated inventory details
      final inventoryRows = await _db.query(
        table: InventoriesTable.tableName,
        where: '${InventoriesTable.id} = ?',
        whereArgs: [entity.inventoryId],
        limit: 1,
      );
      if (inventoryRows.isEmpty) {
        throw Exception('Inventory not found for ID: ${entity.inventoryId}');
      }
      final inventoryMap = inventoryRows.first;
      final inventoryEntity = InventoryItemEntity(
        id: inventoryMap[InventoriesTable.id] as int,
        categoryId: inventoryMap[InventoriesTable.categoryId] as int,
        storeId: inventoryMap[InventoriesTable.storeId] as int,
        propertyAccountId:
            (inventoryMap[InventoriesTable.propertyAccountId] ?? 0) as int,
        revenueAccountId:
            inventoryMap[InventoriesTable.revenueAccountId] as int,
        expenseAccountId:
            inventoryMap[InventoriesTable.expenseAccountId] as int,
        incomeStockId: inventoryMap[InventoriesTable.incomeStockId] as int,
        outcomeStockId: inventoryMap[InventoriesTable.outcomeStockId] as int,
        inventoryName: '',
        costTotal: ((inventoryMap[InventoriesTable.costTotal] ?? 0) as num)
            .toDouble(),
        countUnits: ((inventoryMap[InventoriesTable.countUnits] ?? 0) as num)
            .toDouble(),
        userId: (inventoryMap[InventoriesTable.userId] ?? 1) as int,
      );

      int? journalEntryId = entity.journalEntryId;
      if (journalEntryId == null && oldEntity != null) {
        journalEntryId = oldEntity.journalEntryId;
      }

      if (journalEntryId == null || journalEntryId <= 0) {
        // Insert new journal entry if none existed
        final journalEntry = JournalEntryEntity.fromOpeningQuantity(
          openingQuantity: entity,
          warehouseId: inventoryEntity.storeId,
          userId: inventoryEntity.userId,
        );
        journalEntryId = await _db.insert(
          table: JournalEntriesTable.tableName,
          data: journalEntryToMap(journalEntry),
        );

        if (journalEntryId <= 0) {
          throw Exception('Failed to insert journal entry during update');
        }

        // Insert journal items
        final incomeItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          inventory: inventoryEntity,
          journalEntryId: journalEntryId,
          journalStatus: JournalStatus.increment,
        );
        await _db.insert(
          table: JournalItemsTable.tableName,
          data: journalItemToMap(incomeItem),
        );

        final propertyItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          inventory: inventoryEntity,
          journalEntryId: journalEntryId,
          journalStatus: JournalStatus.decrement,
        );
        await _db.insert(
          table: JournalItemsTable.tableName,
          data: journalItemToMap(propertyItem),
        );
      } else {
        // Update existing journal entry
        final journalEntry = JournalEntryEntity.fromOpeningQuantity(
          openingQuantity: entity,
          warehouseId: inventoryEntity.storeId,
          userId: inventoryEntity.userId,
        ).copyWith(id: journalEntryId);

        await _db.update(
          table: JournalEntriesTable.tableName,
          data: journalEntryToMap(journalEntry),
          where: {JournalEntriesTable.entryId: journalEntryId},
        );

        // Update increment journal item
        final incomeItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          inventory: inventoryEntity,
          journalEntryId: journalEntryId,
          journalStatus: JournalStatus.increment,
        );
        await _db.update(
          table: JournalItemsTable.tableName,
          data: journalItemToMap(incomeItem),
          where: {
            JournalItemsTable.entryId: journalEntryId,
            JournalItemsTable.journalStatus: JournalStatus.increment.name,
          },
        );

        // Update decrement journal item
        final propertyItem = JournalItemEntity.fromOpeningQuantity(
          openingQuantity: entity,
          inventory: inventoryEntity,
          journalEntryId: journalEntryId,
          journalStatus: JournalStatus.decrement,
        );
        await _db.update(
          table: JournalItemsTable.tableName,
          data: journalItemToMap(propertyItem),
          where: {
            JournalItemsTable.entryId: journalEntryId,
            JournalItemsTable.journalStatus: JournalStatus.decrement.name,
          },
        );
      }

      final entityToUpdate = entity.copyWith(journalEntryId: journalEntryId);
      await _db.update(
        table: OpeningQuantitiesTable.tableName,
        data: toMap(entityToUpdate),
        where: {OpeningQuantitiesTable.id: entity.id},
      );
      return entityToUpdate;
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      final oldEntity = await getById(id);
      if (oldEntity != null) {
        final journalEntryId = oldEntity.journalEntryId;
        if (journalEntryId != null && journalEntryId > 0) {
          // Delete journal items first
          await _db.deleteWhere(
            table: JournalItemsTable.tableName,
            where: {JournalItemsTable.entryId: journalEntryId},
          );

          // Delete journal entry
          await _db.deleteWhere(
            table: JournalEntriesTable.tableName,
            where: {JournalEntriesTable.entryId: journalEntryId},
          );
        }
      }

      await _db.deleteWhere(
        table: OpeningQuantitiesTable.tableName,
        where: {OpeningQuantitiesTable.id: id},
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
      table: OpeningQuantitiesTable.tableName,
      where: '${OpeningQuantitiesTable.inventoryId} = ?',
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
      table: OpeningQuantitiesTable.tableName,
      where: '${OpeningQuantitiesTable.inventoryId} = ?',
      whereArgs: [inventoryId],
    );

    return rows.fold<double>(0.0, (sum, row) {
      return sum + ((row[OpeningQuantitiesTable.countUnits] as num).toDouble());
    });
  }

  @override
  Future<List<OpeningQuantityEntity>> whereCommodity(
    InventoryEntity commodity, {
    bool trigger = false,
    bool printQuery = true,
  }) async {
    final rows = await _db.query(
      table: OpeningQuantitiesTable.tableName,
      where: '${OpeningQuantitiesTable.inventoryId} = ?',
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
      table: OpeningQuantitiesTable.tableName,
      where:
          '${OpeningQuantitiesTable.inventoryId} IN (SELECT ${InventoriesTable.id} FROM ${InventoriesTable.tableName} WHERE ${InventoriesTable.storeId} = ?)',
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
}
