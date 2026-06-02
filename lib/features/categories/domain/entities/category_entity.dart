import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';

class CategoryEntity extends Entity {
  final int id;
  final CategoryDefineType categoryType;
  final String categoryName;
  final String categoryNumber;
  final String? barcode;
  final int categoryUnitId;
  final int pricingUnitId;
  final int inventoryUnitId;
  final UnitEntity? categoryUnit;
  final UnitEntity? pricingUnit;
  final UnitEntity? inventoryUnit;
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
    this.categoryUnit,
    this.pricingUnit,
    this.inventoryUnit,
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
    categoryUnit,
    pricingUnit,
    inventoryUnit,
    attributes,
  ];

  CategoryEntity copyWith({
    int? id,
    CategoryDefineType? categoryType,
    String? categoryName,
    String? categoryNumber,
    String? barcode,
    int? categoryUnitId,
    int? pricingUnitId,
    int? inventoryUnitId,
    UnitEntity? categoryUnit,
    UnitEntity? pricingUnit,
    UnitEntity? inventoryUnit,
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
      categoryUnit: categoryUnit ?? this.categoryUnit,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      inventoryUnit: inventoryUnit ?? this.inventoryUnit,
      attributes: attributes ?? this.attributes,
    );
  }
}
