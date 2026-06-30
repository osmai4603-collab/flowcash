import 'dart:isolate';
import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/data/models/subcategory_model.dart';
import 'package:flowcash/features/categories/data/models/subcategory_unit_model.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/data/datasources/subcategory_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/repositories/category_repository.dart';
import 'package:flowcash/features/categories/domain/repositories/main_category_repository.dart';
import 'package:flowcash/features/categories/domain/repositories/subcategory_repository.dart';
import 'package:flowcash/features/categories/domain/repositories/unit_repository.dart';
import 'package:flowcash/features/categories/domain/repositories/category_property_repository.dart';
import 'package:flowcash/features/categories/domain/repositories/category_attribute_repository.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_property_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_attribute_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/unit_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/category_attribute_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/category_property_local_data_source_impl.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_attribute_usecases.dart';
import 'package:flowcash/features/categories/domain/services/category_generation_service.dart';

final class SubcategoryLocalDataSourceImpl
    implements SubcategoryLocalDataSource {
  final SqliteService _db;
  const SubcategoryLocalDataSourceImpl(this._db);

  @override
  Future<List<SubcategoryEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: SubcategoriesTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${SubcategoriesTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<SubcategoryEntity?> getById(int id) async {
    final rows = await _db.query(
      table: SubcategoriesTable().tableName,
      where: '${SubcategoriesTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<SubcategoryEntity> insert(SubcategoryEntity entity) async {
    return await insertWithUnits(entity);
  }

  @override
  Future<SubcategoryEntity> update(SubcategoryEntity entity) async {
    return await saveWithUnits(entity, entity.units);
  }

  @override
  Future<bool> delete(int id) async {
    return await _db.transaction(() async {
      await _db.deleteWhere(
        table: SubcategoriesUnitsTable().tableName,
        where: {SubcategoriesUnitsTable().subcategoryId: id},
      );
      await _db.deleteWhere(
        table: SubcategoriesTable().tableName,
        where: {SubcategoriesTable().id: id},
      );
      return true;
    });
  }

  @override
  SubcategoryEntity fromMap(Map<String, dynamic> map) {
    return SubcategoryEntity(
      id: map[SubcategoriesTable().id],
      mainCategoryId: map[SubcategoriesTable().mainCategoryId] as int,
      catalogName: (map[SubcategoriesTable().catalogName] as String?) ?? "",
      catalogNumber: map[SubcategoriesTable().catalogNumber] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(SubcategoryEntity entity) {
    return {
      if (entity.id > 0) SubcategoriesTable().id: entity.id,
      SubcategoriesTable().mainCategoryId: entity.mainCategoryId,
      SubcategoriesTable().catalogName: entity.catalogName,
      SubcategoriesTable().catalogNumber: entity.catalogNumber,
    };
  }

  @override
  Future<List<SubcategoryEntity>> whereMainCategoryId(Iterable<int> ids) async {
    if (ids.isEmpty) return const [];

    final where =
        '${SubcategoriesTable().mainCategoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubcategoryUnitEntity>> getUnitsBySubcategoryIds(
    Iterable<int> ids,
  ) async {
    if (ids.isEmpty) return const [];

    final where =
        '${SubcategoriesUnitsTable().subcategoryId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubcategoriesUnitsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );

    return rows.map((row) {
      return SubcategoryUnitEntity(
        id: row[SubcategoriesUnitsTable().id] as int,
        subcategoryId: row[SubcategoriesUnitsTable().subcategoryId] as int,
        unitId: row[SubcategoriesUnitsTable().unitId] as int,
        propertyId: row[SubcategoriesUnitsTable().propertyId] as int,
      );
    }).toList();
  }

  @override
  Future<SubcategoryEntity> insertWithUnits(SubcategoryEntity entity) async {
    return await _db.transaction(() async {
      // Insert subcategory
      final subcategoryId = await _db.insert(
        table: SubcategoriesTable().tableName,
        data: _sanitizeInsertData(toMap(entity), SubcategoriesTable().id),
      );

      final savedUnits = <SubcategoryUnitEntity>[];
      for (final unit in entity.units) {
        final toInsert = SubcategoryUnitModel.fromEntity(
          unit.copyWith(subcategoryId: subcategoryId),
        );
        final id = await _db.insert(
          table: SubcategoriesUnitsTable().tableName,
          data: toInsert.toMap(),
        );
        savedUnits.add(toInsert.copyWith(id: id));
      }

      return entity.copyWith(id: subcategoryId, units: savedUnits);
    });
  }

  @override
  Future<SubcategoryUnitEntity> insertSubcategoryUnit(
    SubcategoryUnitEntity entity,
  ) async {
    final id = await _db.insert(
      table: SubcategoriesUnitsTable().tableName,
      data: SubcategoryUnitModel.fromEntity(entity).toMap(),
    );
    return entity.copyWith(id: id);
  }

  @override
  Future<SubcategoryUnitEntity> updateSubcategoryUnit(
    SubcategoryUnitEntity entity,
  ) async {
    await _db.update(
      table: SubcategoriesUnitsTable().tableName,
      data: SubcategoryUnitModel.fromEntity(entity).toMap(),
      where: {SubcategoriesUnitsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<SubcategoryEntity> saveWithUnits(
    SubcategoryEntity entity,
    List<SubcategoryUnitEntity> units,
  ) async {
    return await _db.transaction(() async {
      var persistedEntity = entity;

      if (entity.id > 0) {
        await _db.update(
          table: SubcategoriesTable().tableName,
          data: toMap(entity),
          where: {SubcategoriesTable().id: entity.id},
        );

        final existingRows = await _db.query(
          table: SubcategoriesUnitsTable().tableName,
          where: '${SubcategoriesUnitsTable().subcategoryId} = ?',
          whereArgs: [entity.id],
        );
        final existingIds = existingRows
            .map((row) => row[SubcategoriesUnitsTable().id] as int)
            .toSet();
        final selectedIds = units
            .where((unit) => unit.id > 0)
            .map((unit) => unit.id)
            .toSet();
        final deleteIds = existingIds.difference(selectedIds);

        for (final deleteId in deleteIds) {
          await _db.deleteWhere(
            table: SubcategoriesUnitsTable().tableName,
            where: {SubcategoriesUnitsTable().id: deleteId},
          );
        }
      } else {
        final id = await _db.insert(
          table: SubcategoriesTable().tableName,
          data: SubcategoryModel.fromEntity(entity).toMap(),
        );
        persistedEntity = entity.copyWith(id: id);
      }

      final savedUnits = <SubcategoryUnitEntity>[];
      for (final unit in units) {
        final updatedUnit = unit.copyWith(subcategoryId: persistedEntity.id);
        if (updatedUnit.id > 0) {
          await updateSubcategoryUnit(updatedUnit);
          savedUnits.add(updatedUnit);
        } else {
          final id = await _db.insert(
            table: SubcategoriesUnitsTable().tableName,
            data: SubcategoryUnitModel.fromEntity(updatedUnit).toMap(),
          );
          savedUnits.add(updatedUnit.copyWith(id: id));
        }
      }

      return persistedEntity.copyWith(units: savedUnits);
    });
  }

  @override
  Future<SubcategoryEntity?> firstWhereCategory(int categoryId) async {
    final rows = await _db.query(
      table: SubcategoriesTable().tableName,
      where: '${SubcategoriesTable().id} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<List<CategoryEntity>> generateCategories(int subcategoryId) async {
    final dbPath = await _db.databasePath;
    final result = await Isolate.run(
      () => _generateCategoriesInIsolate(
        _GenerationIsolateInput(dbPath: dbPath, subcategoryId: subcategoryId),
      ),
    );

    return result.fold((failure) => throw failure, (categories) => categories);
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

class _GenerationIsolateInput {
  final String dbPath;
  final int subcategoryId;

  const _GenerationIsolateInput({
    required this.dbPath,
    required this.subcategoryId,
  });
}

Future<Either<Failure, List<CategoryEntity>>> _generateCategoriesInIsolate(
  _GenerationIsolateInput input,
) async {
  sqlite.Database? db;
  try {
    db = sqlite.sqlite3.open(input.dbPath);
    db.execute('PRAGMA foreign_keys = ON');
    SqliteService.overrideDatabase = db;

    final sqliteService = SqliteService();

    final categoryLocalDataSource = CategoryLocalDataSourceImpl(
      sqliteService,
    );

    final mainCategoryLocalDataSource = MainCategoryLocalDataSourceImpl(
      sqliteService,
    );

    final subcategoryLocalDataSource = SubcategoryLocalDataSourceImpl(
      sqliteService,
    );

    final unitLocalDataSource = UnitLocalDataSourceImpl(sqliteService);
    final categoryAttributeDataSource = CategoryAttributeLocalDataSourceImpl(
      sqliteService,
    );
    final categoryPropertyDataSource = CategoryPropertyLocalDataSourceImpl(
      sqliteService,
    );

    final categoryRepo = _IsolateCategoryRepository(categoryLocalDataSource);
    final mainCategoryRepo = _IsolateMainCategoryRepository(
      mainCategoryLocalDataSource,
      categoryPropertyDataSource,
    );
    final subcategoryRepo = _IsolateSubcategoryRepository(
      subcategoryLocalDataSource,
    );
    final unitRepo = _IsolateUnitRepository(unitLocalDataSource);
    final categoryPropertyRepo = _IsolateCategoryPropertyRepository(
      categoryPropertyDataSource,
    );
    final categoryAttributeRepo = _IsolateCategoryAttributeRepository(
      categoryAttributeDataSource,
    );

    final service = CategoryGenerationService(
      usecases: CategoriesUsecases(
        getMainCategoryById: GetMainCategoryByIdUseCase(mainCategoryRepo),
        getSubcategoryById: GetSubcategoryByIdUseCase(subcategoryRepo),
        getCategoryPropertiesByMainCategory:
            GetCategoryPropertiesByMainCategoryUseCase(categoryPropertyRepo),
        getSubcategoryUnitsBySubcategoryIds:
            GetSubcategoryUnitsBySubcategoryIdsUseCase(subcategoryRepo),
        getUnits: GetUnitsUseCase(unitRepo),
        getBasicUnits: GetBasicUnits(unitRepo),
        addCategory: AddCategoryUseCase(categoryRepo),
        addCategoryAttribute: AddCategoryAttributeUseCase(
          categoryAttributeRepo,
        ),
        hasCategoryName: HasCategoryNameUseCase(categoryRepo),
        getNewCategoryNumber: GetNewCategoryNumberUseCase(categoryRepo),
      ),
    );

    return await service.generate(input.subcategoryId);
  } catch (e) {
    if (e is Failure) {
      return Left(e);
    }
    return Left(ServerFailure(e.toString()));
  } finally {
    SqliteService.overrideDatabase = null;
    db?.dispose();
  }
}

class _IsolateCategoryRepository implements CategoryRepository {
  final CategoryLocalDataSource db;
  const _IsolateCategoryRepository(this.db);

  @override
  Future<Either<Failure, CategoryEntity>> insert(CategoryEntity entity) async {
    try {
      final res = await db.insert(entity);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity?>> firstWhereCategoryName(
    String categoryName,
  ) async {
    try {
      final res = await db.firstWhereCategoryName(categoryName);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getNewCategoryNumber() async {
    try {
      final res = await db.getNewCategoryNumber();
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> hasCategoryName(String categoryName) async {
    try {
      final res = await db.hasCategoryName(categoryName);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IsolateMainCategoryRepository implements MainCategoryRepository {
  final MainCategoryLocalDataSource db;
  final CategoryPropertyDataSource propertyDb;
  const _IsolateMainCategoryRepository(this.db, this.propertyDb);

  @override
  Future<Either<Failure, MainCategoryEntity?>> getById(
    int id, {
    bool getItems = false,
  }) async {
    try {
      final cat = await db.getById(id);
      if (cat == null) return const Right(null);
      final props = await propertyDb.whereMainCategoryId([cat.id]);
      return Right(cat.copyWith(properties: props));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  
}

class _IsolateSubcategoryRepository implements SubcategoryRepository {
  final SubcategoryLocalDataSource db;
  const _IsolateSubcategoryRepository(this.db);

  @override
  Future<Either<Failure, SubcategoryEntity?>> getById(
    int id, {
    bool getItems = false,
  }) async {
    try {
      final res = await db.getById(id);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryUnitEntity>>> getUnitsBySubcategoryIds(
    Iterable<int> ids,
  ) async {
    try {
      final res = await db.getUnitsBySubcategoryIds(ids);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IsolateUnitRepository implements UnitRepository {
  final UnitLocalDataSource db;
  const _IsolateUnitRepository(this.db);

  @override
  Future<Either<Failure, List<UnitEntity>>> get({Iterable<int>? ids}) async {
    try {
      final res = await db.get(ids: ids);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnitEntity>>> whereBasic() async {
    try {
      final res = await db.whereBasic();
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IsolateCategoryPropertyRepository implements CategoryPropertyRepository {
  final CategoryPropertyDataSource db;
  const _IsolateCategoryPropertyRepository(this.db);

  @override
  Future<Either<Failure, List<CategoryPropertyEntity>>> whereMainCategoryId(
    Iterable<int> ids,
  ) async {
    try {
      final res = await db.whereMainCategoryId(ids);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IsolateCategoryAttributeRepository
    implements CategoryAttributeRepository {
  final CategoryAttributeDataSource db;
  const _IsolateCategoryAttributeRepository(this.db);

  @override
  Future<Either<Failure, CategoryAttributeEntity>> insert(
    CategoryAttributeEntity entity,
  ) async {
    try {
      final res = await db.insert(entity);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
