import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';

class CategoryEntity extends Entity {
  final int id;
  final CategoryDefineType categoryType;
  final String categoryName;
  final String categoryNumber;
  final String? barcode;
  final int categoryUnitId;
  final int pricingUnitId;
  final int inventoryUnitId;
  final int? subcategoryId;
  final UnitEntity? categoryUnit;
  final UnitEntity? pricingUnit;
  final UnitEntity? inventoryUnit;
  final SubcategoryEntity? subcategory;
  final List<CategoryAttributeEntity> attributes;

  const CategoryEntity({
    this.id = 0,
    required this.categoryType,
    this.categoryName = '',
    this.categoryNumber = '',
    this.barcode,
    this.categoryUnitId = 0,
    this.pricingUnitId = 0,
    this.inventoryUnitId = 0,
    this.subcategoryId,
    this.categoryUnit,
    this.pricingUnit,
    this.inventoryUnit,
    this.subcategory,
    this.attributes = const [],
  });

  @override
  List<Object?> get props => [
    id,
    categoryType,
    categoryName,
    categoryNumber,
    barcode,
    categoryUnitId,
    pricingUnitId,
    inventoryUnitId,
    subcategoryId,
    categoryUnit,
    pricingUnit,
    inventoryUnit,
    subcategory,
    attributes,
  ];

  @override
  CategoryEntity copyWith({
    int? id,
    CategoryDefineType? categoryType,
    String? categoryName,
    String? categoryNumber,
    String? barcode,
    int? categoryUnitId,
    int? pricingUnitId,
    int? inventoryUnitId,
    int? subcategoryId,
    UnitEntity? categoryUnit,
    UnitEntity? pricingUnit,
    UnitEntity? inventoryUnit,
    SubcategoryEntity? subcategory,
    List<CategoryAttributeEntity>? attributes,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      categoryType: categoryType ?? this.categoryType,
      categoryName: categoryName ?? this.categoryName,
      categoryNumber: categoryNumber ?? this.categoryNumber,
      barcode: barcode ?? this.barcode,
      categoryUnitId: categoryUnitId ?? this.categoryUnitId,
      pricingUnitId: pricingUnitId ?? this.pricingUnitId,
      inventoryUnitId: inventoryUnitId ?? this.inventoryUnitId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      inventoryUnit: inventoryUnit ?? this.inventoryUnit,
      subcategory: subcategory ?? this.subcategory,
      attributes: attributes ?? this.attributes,
    );
  }
}
