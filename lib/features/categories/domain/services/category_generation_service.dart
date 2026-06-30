import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/utils/combinatorics_utils.dart';

import '../entities/category_attribute_entity.dart';
import '../entities/category_entity.dart';
import '../entities/category_property_entity.dart';
import '../entities/main_category_entity.dart';
import '../entities/subcategory_entity.dart';
import '../entities/subcategory_unit_entity.dart';
import '../entities/unit_entity.dart';

import '../usecases/category_property_usecases.dart';
import '../usecases/category_usecases.dart';
import '../usecases/main_category_usecases.dart';
import '../usecases/unit_usecases.dart';
import '../usecases/subcategory_usecases.dart';
import '../usecases/category_attribute_usecases.dart';

class CategoriesUsecases {
  final GetMainCategoryByIdUseCase getMainCategoryById;
  final GetSubcategoryByIdUseCase getSubcategoryById;
  final GetCategoryPropertiesByMainCategoryUseCase
  getCategoryPropertiesByMainCategory;
  final GetSubcategoryUnitsBySubcategoryIdsUseCase
  getSubcategoryUnitsBySubcategoryIds;
  final GetUnitsUseCase getUnits;
  final GetBasicUnits getBasicUnits;
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
    required this.getBasicUnits,
    required this.addCategory,
    required this.addCategoryAttribute,
    required this.hasCategoryName,
    required this.getNewCategoryNumber,
  });
}

class CategoryGenerationService {
  final CategoriesUsecases usecases;

  CategoryGenerationService({required this.usecases});

  Future<Either<Failure, List<CategoryEntity>>> generate(
    int subcategoryId,
  ) async {
    try {
      // 1. Fetch Subcategory (Catalog)
      final catalogResult = await usecases.getSubcategoryById(subcategoryId);
      final catalog = catalogResult.getOrElse((l) => throw l)!;

      // 2. Fetch MainCategory
      final mainCategoryResult = await usecases.getMainCategoryById(
        catalog.mainCategoryId,
      );
      final mainCategory = mainCategoryResult.getOrElse((l) => throw l)!;

      // 3. Fetch Properties
      final propertiesResult = await usecases
          .getCategoryPropertiesByMainCategory(mainCategory.id);
      final properties = List<CategoryPropertyEntity>.from(
        propertiesResult.getOrElse((l) => throw l),
      );

      // Sort properties by unitType serial
      properties.sort((a, b) => a.unitType.serial.compareTo(b.unitType.serial));

      // 4. Fetch Subcategory Units (Infos)
      final subcategoriesUnitsResult = await usecases
          .getSubcategoryUnitsBySubcategoryIds([subcategoryId]);
      final infos = subcategoriesUnitsResult.getOrElse((l) => throw l);

      if (infos.isEmpty) {
        debugPrint(
          'No subcategory units available to generate categories. Skipping.',
        );
        return const Right([]);
      }

      // 5. Fetch all required Units
      final unitsIds = infos.map((e) => e.unitId).toList();
      final unitsResult = await usecases.getUnits(ids: unitsIds);
      final units = unitsResult.getOrElse((l) => throw l);

      // Fetch basic units to determine categoryUnitId
      final basicUnitsResult = await usecases.getBasicUnits();
      final basicUnits = basicUnitsResult.getOrElse((l) => throw l);

      // 6. Group SubcategoryUnits by Property
      // This will be our input for the Cartesian product
      List<List<SubcategoryUnitEntity>> propertyValuesLists = [];
      List<CategoryPropertyEntity> activeProperties = [];

      for (final property in properties) {
        final propertyInfos = infos
            .where((info) => info.propertyId == property.id)
            .toList();
        if (propertyInfos.isNotEmpty) {
          propertyValuesLists.add(propertyInfos);
          activeProperties.add(property);
        }
      }

      if (propertyValuesLists.isEmpty) {
        debugPrint('No active properties with values available. Skipping.');
        return const Right([]);
      }

      // 7. Generate Cartesian Product
      final combinations = CombinatoricsUtils.cartesianProduct(
        propertyValuesLists,
      );
      List<CategoryEntity> generatedCategories = [];

      // 8. Process each combination
      for (final combination in combinations) {
        final categoryName = _getCategoryName(
          mainCategory: mainCategory,
          catalog: catalog,
          combination: combination,
          activeProperties: activeProperties,
          units: units,
        );

        // Check if category exists
        final hasCategoryNameResult = await usecases.hasCategoryName(
          categoryName,
        );
        final hasCategoryName = hasCategoryNameResult.getOrElse((l) => throw l);

        if (hasCategoryName) {
          debugPrint(
            'Category with name $categoryName already exists, skipping...',
          );
          continue;
        }

        // Determine units
        final categoryUnit = basicUnits.firstWhere(
          (u) => u.id == mainCategory.categoryUnitId,
          orElse: () =>
              throw 'No basic unit found for the main category unit type.',
        );
        final pricingUnit = _getUnitForRole(
          combination,
          activeProperties,
          units,
          mainCategory,
          (p) => p.isPricingUnit,
        );
        final inventoryUnit = _getUnitForRole(
          combination,
          activeProperties,
          units,
          mainCategory,
          (p) => p.isInventoryUnit,
        );

        // Get new category number
        final categoryNumberResult = await usecases.getNewCategoryNumber();
        final categoryNumber = categoryNumberResult
            .getOrElse((l) => '0')
            .toString();

        // Prepare Attributes
        final attributes = List.generate(combination.length, (index) {
          return CategoryAttributeEntity(
            id: 0,
            subcategoryUnitId: combination[index].id,
            categoryId: 0, // Will be set by DataSource
          );
        });

        // Prepare Category Entity with Attributes
        CategoryEntity newCategory = CategoryEntity(
          id: 0,
          categoryName: categoryName,
          categoryUnitId: categoryUnit.id,
          pricingUnitId: pricingUnit.id,
          inventoryUnitId: inventoryUnit.id,
          categoryNumber: categoryNumber,
          barcode: null,
          categoryType: mainCategory.type,
          subcategoryId: subcategoryId,
          attributes: attributes,
        );

        // Save Category (and its attributes automatically via DataSource transaction)
        final addCategoryResult = await usecases.addCategory(
          category: newCategory,
        );
        newCategory = addCategoryResult.getOrElse((l) => throw l);

        generatedCategories.add(newCategory);
      }

      return Right(generatedCategories);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getCategoryName({
    required MainCategoryEntity mainCategory,
    required SubcategoryEntity catalog,
    required List<SubcategoryUnitEntity> combination,
    required List<CategoryPropertyEntity> activeProperties,
    required List<UnitEntity> units,
  }) {
    final List<String> mainUnits = [];
    final List<String> subUnits = [];

    for (int i = 0; i < combination.length; i++) {
      final info = combination[i];
      final property = activeProperties[i];

      if (property.isSingle && property.unitType.isPiece) continue;
      if (property.unitType.isLinearMeter && property.isCategoryUnit) continue;

      final unitIndex = units.indexWhere((u) => u.id == info.unitId);
      if (unitIndex >= 0 && units[unitIndex].unitType.canWriteUnitOnCategory) {
        final unitName = units[unitIndex].unitName;
        if (property.unitType.isMainCategory) {
          mainUnits.add(unitName);
        } else {
          subUnits.add(unitName);
        }
      }
    }

    final List<String> names = [
      mainCategory.name,
      ...mainUnits,
      catalog.catalogName,
      ...subUnits,
    ];

    names.removeWhere((e) => e.isEmpty || e == ' ');
    return names.join(' ');
  }

  UnitEntity _getUnitForRole(
    List<SubcategoryUnitEntity> combination,
    List<CategoryPropertyEntity> activeProperties,
    List<UnitEntity> units,
    MainCategoryEntity mainCategory,
    bool Function(CategoryPropertyEntity) rolePredicate,
  ) {
    int index = activeProperties.indexWhere(rolePredicate);

    // Fallback: match mainCategory unitType
    if (index < 0) {
      index = activeProperties.indexWhere(
        (p) => p.isCategoryUnit,
      );
    }

    // Final fallback: first available
    if (index < 0) {
      if (activeProperties.isEmpty) {
        throw 'No properties available to determine unit role.';
      }
      index = 0;
    }

    final info = combination[index];
    final unit = units.firstWhere(
      (u) => u.id == info.unitId,
      orElse: () {
        if (units.isEmpty) throw 'No units available for selected property.';
        return units.first;
      },
    );

    return unit;
  }
}
