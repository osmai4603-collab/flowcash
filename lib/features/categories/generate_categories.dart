import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'domain/entities/category_attribute_entity.dart';
import 'domain/entities/category_entity.dart';
import 'domain/entities/category_property_entity.dart';
import 'domain/entities/main_category_entity.dart';
import 'domain/entities/subcategory_entity.dart';
import 'domain/entities/subcategory_unit_entity.dart';
import 'domain/entities/unit_entity.dart';
import 'domain/usecases/category_property_usecases.dart';
import 'domain/usecases/category_usecases.dart';
import 'domain/usecases/main_category_usecases.dart';
import 'domain/usecases/unit_usecases.dart';
import 'domain/usecases/subcategory_usecases.dart';
import 'domain/usecases/category_attribute_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'presentation/blocs/categories/categories_bloc.dart';
import 'presentation/blocs/categories/categories_event.dart';

class CategoriesUsecases {
  final GetMainCategoryByIdUseCase getMainCategoryById;
  final GetSubcategoryByIdUseCase getSubcategoryById;
  final GetCategoryPropertiesByMainCategoryUseCase
  getCategoryPropertiesByMainCategory;
  final GetSubcategoryUnitsBySubcategoryIdsUseCase
  getSubcategoryUnitsBySubcategoryIds;
  final GetUnitsUseCase getUnits;
  final AddCategoryUseCase addCategory;
  final AddCategoryAttributeUseCase addCategoryAttribute;
  final HasCategoryNameUseCase hasCategoryName;
  final GetNewCategoryNumberUseCase getNewCategoryNumber;

  CategoriesUsecases({
    required this.getMainCategoryById,
    required this.getSubcategoryById,
    required this.getCategoryPropertiesByMainCategory,
    required this.getSubcategoryUnitsBySubcategoryIds,
    required this.getUnits,
    required this.addCategory,
    required this.addCategoryAttribute,
    required this.hasCategoryName,
    required this.getNewCategoryNumber,
  });
}

class GenerateCategories {
  late final SubcategoryEntity catalog;
  late final MainCategoryEntity mainCategory;

  late final List<UnitEntity> units;
  late final CategoriesUsecases usecases;

  GenerateCategories({required this.usecases});

  List<int> get unitsIds {
    return infos.map((e) => e.unitId).toList();
  }

  late final List<Indexer> indexers;

  late final List<SubcategoryUnitEntity> infos;

  late final List<CategoryPropertyEntity> properties;

  Future<List<CategoryEntity>> startGeneratingCategories(
    int subcategoryId,
  ) async {
    List<CategoryEntity> categories = [];
    final resultOfCatalog = await usecases.getSubcategoryById(subcategoryId);
    catalog = resultOfCatalog.fold((l) => throw l, (r) => r!);

    final resultOfMaincategory = await usecases.getMainCategoryById(
      catalog.mainCategoryId,
    );
    mainCategory = resultOfMaincategory.fold((l) => throw l, (r) => r!);

    final resultOfProperties = await usecases
        .getCategoryPropertiesByMainCategory(mainCategory.id);
    properties = resultOfProperties.fold((l) => throw l, (r) => r);

    mainCategory.properties.sort(
      (a, b) => a.unitType.serial.compareTo(b.unitType.serial),
    );

    final resultOfSubcategoriesUnits = await usecases
        .getSubcategoryUnitsBySubcategoryIds([subcategoryId]);
    infos = resultOfSubcategoriesUnits.fold((l) => throw l, (r) => r);

    indexers = [];
    units = await usecases
        .getUnits(ids: unitsIds)
        .then((result) => result.fold((l) => throw l, (r) => r));
    for (final property in properties) {
      final infos = this.infos
          .where((info) => info.propertyId == property.id)
          .toList();
      final unitsIds = infos.map((e) => e.unitId).toList();
      final units = this.units
          .where((unit) => unitsIds.contains(unit.id))
          .toList();
      indexers.add(
        Indexer(
          property: property,
          indexOfProperty: properties.indexOf(property),
          values: infos,
          units: units,
        ),
      );
    }
    debugPrint('Start insert categories');
    do {
      final category = await _generateCategory(subcategoryId);
      _incrementIndexOfValue(indexers.last);
      debugPrint(
        'indexers: ${indexers.map((indexer) => indexer.currentIndex).join(', ')}---------------------------------',
      );
      if (category == null) continue;
      categories.add(category);
    } while (indexers.fold(0, (int pre, next) => pre + next.currentIndex) > 0);

    return categories;
  }

  void _incrementIndexOfValue(Indexer indexer) {
    indexer.increment();
    if (indexer.currentIndex == 0) {
      final index = indexers.indexWhere(
        (index) => index.indexOfProperty == (indexer.indexOfProperty - 1),
      );
      if (index > -1) _incrementIndexOfValue(indexers[index]);
    }
  }

  String _getCategoryName() {
    final names = [
      mainCategory.name,
      catalog.catalogName,
      ...indexers.map((indexer) => indexer.getCurrentData),
    ];
    names.removeWhere((e) => e.isEmpty || e == ' ');
    debugPrint('category name: ${names.join(' ')}');
    return names.join(' ');
  }

  Future<CategoryEntity?> _getCategory(int catalogId) async {
    final categoryName = _getCategoryName();
    final resultOfHasCategoryName = await usecases.hasCategoryName(
      categoryName,
    );
    final hasCategoryName = resultOfHasCategoryName.fold(
      (l) => throw l,
      (r) => r,
    );
    if (hasCategoryName) {
      debugPrint(
        'Category with name $categoryName already exists, skipping...',
      );
      return null;
    }
    final categoryUnit = await _getCurrentUnitOfCategory();
    final pricingUnit = await _getCurrentUnitOfPricing();
    final inventoryUnit = await _getCurrentUnitOfInventory();
    final info = CategoryEntity(
      id: 0,
      categoryName: categoryName,
      categoryUnitId: categoryUnit.id,
      pricingUnitId: pricingUnit.id,
      inventoryUnitId: inventoryUnit.id,
      categoryNumber: (await usecases.getNewCategoryNumber()).fold(
        (left) => '0',
        (right) => right.toString(),
      ),
      barcode: null,
      categoryType: CategoryDefineType.commodities,
    );
    return info;
  }

  Future<CategoryEntity?> _generateCategory(int subcategoryId) async {
    var category = await _getCategory(subcategoryId);
    if (category == null) return null;
    final result = await usecases.addCategory(category: category);
    category = result.fold((l) => throw l, (r) => category!.copyWith(id: r));

    final catalogsInfos = indexers
        .map((indexer) => indexer.getCurrentSubcategoryUnit)
        .toList();

    final attributes = List.generate(catalogsInfos.length, (index) {
      return CategoryAttributeEntity(
        id: 0,
        subcategoryUnitId: catalogsInfos[index].id,
        categoryId: category!.id,
      );
    });
    category = category.copyWith(attributes: attributes);
    for (var attribute in category.attributes) {
      await usecases.addCategoryAttribute(attribute);
    }
    try {
      // Inject category to CategoriesBloc so UI can update in real time
      sl<CategoriesBloc>().add(InjectCategoryEvent(category));
    } catch (e) {
      debugPrint('Failed to inject category to CategoriesBloc: $e');
    }
    return category;
  }

    // After category is fully created (with attributes), inject it into CategoriesBloc
    // so UI can listen and update in real time.

  Future<UnitEntity> _getCurrentUnitOfCategory() async {
    // Find the indexer marked as category unit
    var indexOfIndexer = indexers.indexWhere(
      (indexer) => indexer.property.isCategoryUnit,
    );
    // Fallback: find indexer with same unitType as main category
    if (indexOfIndexer < 0) {
      indexOfIndexer = indexers.indexWhere(
        (indexer) => indexer.property.unitType == mainCategory.unitType,
      );
    }
    // Final fallback: use first indexer if available
    if (indexOfIndexer < 0) {
      if (indexers.isEmpty) throw 'No indexers available to determine category unit';
      indexOfIndexer = 0;
    }
    final indexer = indexers[indexOfIndexer];
    final info = indexer.getCurrentSubcategoryUnit;
    var indexOfUnit = indexer.units.indexWhere((unit) => unit.id == info.unitId);
    if (indexOfUnit < 0) {
      if (indexer.units.isEmpty) throw 'No units available for selected indexer';
      indexOfUnit = 0; // fallback to first unit
    }
    return indexer.units[indexOfUnit];
  }

  Future<UnitEntity> _getCurrentUnitOfPricing() async {
    var indexOfIndexer = indexers.indexWhere(
      (indexer) => indexer.property.isPricingUnit,
    );
    if (indexOfIndexer < 0) {
      indexOfIndexer = indexers.indexWhere(
        (indexer) => indexer.property.unitType == mainCategory.unitType,
      );
    }
    if (indexOfIndexer < 0) {
      if (indexers.isEmpty) throw 'No indexers available to determine pricing unit';
      indexOfIndexer = 0;
    }
    final indexer = indexers[indexOfIndexer];
    final info = indexer.getCurrentSubcategoryUnit;
    var indexOfUnit = indexer.units.indexWhere((unit) => unit.id == info.unitId);
    if (indexOfUnit < 0) {
      if (indexer.units.isEmpty) throw 'No units available for selected indexer';
      indexOfUnit = 0;
    }
    return indexer.units[indexOfUnit];
  }

  Future<UnitEntity> _getCurrentUnitOfInventory() async {
    var indexOfIndexer = indexers.indexWhere(
      (indexer) => indexer.property.isInventoryUnit,
    );
    if (indexOfIndexer < 0) {
      indexOfIndexer = indexers.indexWhere(
        (indexer) => indexer.property.unitType == mainCategory.unitType,
      );
    }
    if (indexOfIndexer < 0) {
      if (indexers.isEmpty) throw 'No indexers available to determine inventory unit';
      indexOfIndexer = 0;
    }
    final indexer = indexers[indexOfIndexer];
    final info = indexer.getCurrentSubcategoryUnit;
    var indexOfUnit = indexer.units.indexWhere((unit) => unit.id == info.unitId);
    if (indexOfUnit < 0) {
      if (indexer.units.isEmpty) throw 'No units available for selected indexer';
      indexOfUnit = 0;
    }
    return indexer.units[indexOfUnit];
  }
}

class Indexer {
  final CategoryPropertyEntity property;
  final int indexOfProperty;

  List<SubcategoryUnitEntity> values;
  final List<UnitEntity> units;

  Indexer({
    required this.property,
    required this.indexOfProperty,
    required this.values,
    required this.units,
  }) {
    assert(
      values.isNotEmpty,
      'Values Can not be empty on property:\n    ${property.toString()}',
    );
  }

  int _currentIndex = 0;
  int get currentIndex {
    return _currentIndex;
  }

  SubcategoryUnitEntity get getCurrentSubcategoryUnit {
    if (currentIndex >= values.length || currentIndex < 0) {
      throw 'Error Index $currentIndex values length: ${values.length} \n  ${property.toString()}';
    }
    return values[currentIndex];
  }

  void increment() {
    _currentIndex = (currentIndex + 1) % values.length;
  }

  String get getCurrentData {
    if (property.isSingle && property.unitType.isPiece) return '';
    if (property.unitType.isLinearMeter && property.isCategoryUnit) return '';
    final info = getCurrentSubcategoryUnit;
    final index = units.indexWhere((unit) => unit.id == info.unitId);
    if (index < 0) {
      throw 'Index Can Not Be $index on get Unit from ${info.toString()}';
    }
    return units[index].unitType.canWriteUnitOnCategory
        ? units[index].unitName
        : '';
  }
}
