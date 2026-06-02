import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

enum SubcategoryFormStatus { initial, ready, saving, saved, failure }

class SubcategoryFormState extends Equatable {
  final int catalogId;
  final SubcategoryFormStatus status;
  final MainCategoryEntity? mainCategory;
  final String? catalogName;
  final String? catalogNumber;
  final List<SubcategoryProperty> catalogProperties;
  final SubcategoryEntity? savedSubcategory;
  final String? messageError;

  const SubcategoryFormState({
    this.catalogId = 0,
    this.status = SubcategoryFormStatus.initial,
    this.mainCategory,
    this.catalogName,
    this.catalogNumber,
    this.catalogProperties = const [],
    this.savedSubcategory,
    this.messageError,
  });

  SubcategoryFormState copyWith({
    int? catalogId,
    SubcategoryFormStatus? status,
    MainCategoryEntity? mainCategory,
    String? catalogName,
    String? catalogNumber,
    List<SubcategoryProperty>? catalogProperties,
    SubcategoryEntity? savedSubcategory,
    String? messageError,
  }) {
    return SubcategoryFormState(
      catalogId: catalogId ?? this.catalogId,
      status: status ?? this.status,
      mainCategory: mainCategory ?? this.mainCategory,
      catalogName: catalogName ?? this.catalogName,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      catalogProperties: catalogProperties ?? this.catalogProperties,
      savedSubcategory: savedSubcategory ?? this.savedSubcategory,
      messageError: messageError ?? this.messageError,
    );
  }

  @override
  List<Object?> get props => [
    catalogId,
    status,
    mainCategory,
    catalogName,
    catalogNumber,
    catalogProperties,
    savedSubcategory,
    messageError,
  ];

  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
      id: catalogId,
      mainCategoryId: mainCategory?.id ?? 0,
      catalogName: catalogName ?? "",
      catalogNumber: catalogNumber,
      units: catalogProperties
          .expand(
            (property) => property.selectedUnits
                .whereType<SubcategoryUnit>()
                .map((unit) => unit.toEntity(catalogId)),
          )
          .toList(),
    );
  }
}

class SubcategoryUnit {
  final int id;
  final CategoryPropertyEntity property;
  final UnitEntity unit;

  SubcategoryUnit({this.id = 0, required this.property, required this.unit});

  int get propertyId => property.id;
  int get unitId => unit.id;

  String propertyName() {
    return property.propertyName;
  }

  String unitName() {
    return unit.getCategoryName();
  }

  SubcategoryUnitEntity toEntity(int subcategoryId) {
    return SubcategoryUnitEntity(
      id: id,
      propertyId: propertyId,
      unitId: unitId,
      subcategoryId: subcategoryId,
    );
  }

  String get catalogInfoKey => '${property.id}_${unit.id}';
}

class SubcategoryProperty {
  final CategoryPropertyEntity property;
  final List<SubcategoryUnit> catalogUnits;
  final List<SubcategoryUnit?> selectedUnits;

  int get propertyId => property.id;
  bool get isSingle => property.isSingle;

  SubcategoryProperty({
    required this.property,
    required this.catalogUnits,
    required this.selectedUnits,
  });

  SubcategoryProperty copyWith({
    List<SubcategoryUnit>? catalogUnits,
    List<SubcategoryUnit?>? selectedUnits,
  }) {
    return SubcategoryProperty(
      property: property,
      catalogUnits: catalogUnits ?? this.catalogUnits,
      selectedUnits: selectedUnits ?? this.selectedUnits,
    );
  }

  SubcategoryUnit createSubcategoryUnit({required UnitEntity unit}) {
    return SubcategoryUnit(property: property, unit: unit);
  }
}
