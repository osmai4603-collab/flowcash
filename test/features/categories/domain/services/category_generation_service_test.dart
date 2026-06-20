import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/services/category_generation_service.dart';

import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_attribute_usecases.dart';

class StubGetMainCategoryByIdUseCase implements GetMainCategoryByIdUseCase {
  late Future<Either<Failure, MainCategoryEntity?>> Function(int) callStub;
  @override
  Future<Either<Failure, MainCategoryEntity?>> call(int id) => callStub(id);
}

class StubGetSubcategoryByIdUseCase implements GetSubcategoryByIdUseCase {
  late Future<Either<Failure, SubcategoryEntity?>> Function(int) callStub;
  @override
  Future<Either<Failure, SubcategoryEntity?>> call(int id) => callStub(id);
}

class StubGetCategoryPropertiesByMainCategoryUseCase
    implements GetCategoryPropertiesByMainCategoryUseCase {
  late Future<Either<Failure, List<CategoryPropertyEntity>>> Function(int)
  callStub;
  @override
  Future<Either<Failure, List<CategoryPropertyEntity>>> call(int id) =>
      callStub(id);
}

class StubGetSubcategoryUnitsBySubcategoryIdsUseCase
    implements GetSubcategoryUnitsBySubcategoryIdsUseCase {
  late Future<Either<Failure, List<SubcategoryUnitEntity>>> Function(List<int>)
  callStub;
  @override
  Future<Either<Failure, List<SubcategoryUnitEntity>>> call(List<int> ids) =>
      callStub(ids);
}

class StubGetUnitsUseCase implements GetUnitsUseCase {
  late Future<Either<Failure, List<UnitEntity>>> Function({Iterable<int>? ids})
  callStub;
  @override
  Future<Either<Failure, List<UnitEntity>>> call({Iterable<int>? ids}) =>
      callStub(ids: ids);
}

class StubAddCategoryUseCase implements AddCategoryUseCase {
  late Future<Either<Failure, int>> Function({required CategoryEntity category})
  callStub;
  @override
  Future<Either<Failure, int>> call({required CategoryEntity category}) =>
      callStub(category: category);
}

class StubAddCategoryAttributeUseCase implements AddCategoryAttributeUseCase {
  late Future<Either<Failure, CategoryAttributeEntity>> Function(
    CategoryAttributeEntity,
  )
  callStub;
  @override
  Future<Either<Failure, CategoryAttributeEntity>> call(
    CategoryAttributeEntity attribute,
  ) => callStub(attribute);
}


class StubGetBasicUnitsUseCase implements GetBasicUnits {
  late Future<Either<Failure, List<UnitEntity>>> Function() callStub;
  @override
  Future<Either<Failure, List<UnitEntity>>> call() => callStub();
}

class StubHasCategoryNameUseCase implements HasCategoryNameUseCase {
  late Future<Either<Failure, bool>> Function(String) callStub;
  @override
  Future<Either<Failure, bool>> call(String name) => callStub(name);
}

class StubGetNewCategoryNumberUseCase implements GetNewCategoryNumberUseCase {
  late Future<Either<Failure, String>> Function() callStub;
  @override
  Future<Either<Failure, String>> call() => callStub();
}

void main() {
  late CategoryGenerationService service;
  late StubGetMainCategoryByIdUseCase stubGetMainCategory;
  late StubGetSubcategoryByIdUseCase stubGetSubcategory;
  late StubGetCategoryPropertiesByMainCategoryUseCase stubGetProperties;
  late StubGetSubcategoryUnitsBySubcategoryIdsUseCase stubGetUnitsInfos;
  late StubGetUnitsUseCase stubGetUnits;
  late StubAddCategoryUseCase stubAddCategory;
  late StubAddCategoryAttributeUseCase stubAddAttribute;
  late StubHasCategoryNameUseCase stubHasName;
  late StubGetNewCategoryNumberUseCase stubGetNewNumber;
  late StubGetBasicUnitsUseCase stubGetBasicUnitsUseCase;

  setUp(() {
    stubGetMainCategory = StubGetMainCategoryByIdUseCase();
    stubGetSubcategory = StubGetSubcategoryByIdUseCase();
    stubGetProperties = StubGetCategoryPropertiesByMainCategoryUseCase();
    stubGetUnitsInfos = StubGetSubcategoryUnitsBySubcategoryIdsUseCase();
    stubGetUnits = StubGetUnitsUseCase();
    stubAddCategory = StubAddCategoryUseCase();
    stubAddAttribute = StubAddCategoryAttributeUseCase();
    stubHasName = StubHasCategoryNameUseCase();
    stubGetNewNumber = StubGetNewCategoryNumberUseCase();
    stubGetBasicUnitsUseCase = StubGetBasicUnitsUseCase();


    final usecases = CategoriesUsecases(
      getMainCategoryById: stubGetMainCategory,
      getSubcategoryById: stubGetSubcategory,
      getCategoryPropertiesByMainCategory: stubGetProperties,
      getSubcategoryUnitsBySubcategoryIds: stubGetUnitsInfos,
      getUnits: stubGetUnits,
      addCategory: stubAddCategory,
      addCategoryAttribute: stubAddAttribute,
      hasCategoryName: stubHasName,
      getNewCategoryNumber: stubGetNewNumber,
      getBasicUnits: stubGetBasicUnitsUseCase,
    );

    service = CategoryGenerationService(usecases: usecases);
  });

  test('should return Right([]) if no units are available', () async {
    // Arrange
    final catalog = SubcategoryEntity(
      id: 1,
      catalogName: 'Catalog 1',
      mainCategoryId: 1,
    );
    final mainCategory = MainCategoryEntity(
      id: 1,
      name: 'Main 1',
      unitType: UnitType.piece,
      unitName: 'Piece',
      type: CategoryDefineType.commodities,
      properties: [],
    );

    stubGetSubcategory.callStub = (int id) async => Right(catalog);
    stubGetMainCategory.callStub = (int id) async => Right(mainCategory);
    stubGetProperties.callStub = (int id) async => Right(<CategoryPropertyEntity>[]);
    stubGetUnitsInfos.callStub = (List<int> ids) async => Right(<SubcategoryUnitEntity>[]);

    // Act
    final result = await service.generate(1);

    // Assert
    expect(result, const Right<Failure, List<CategoryEntity>>([]));
  });
}
