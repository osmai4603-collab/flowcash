import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

final class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.categoryName,
    required super.barcode,
    required super.categoryNumber,
    required super.categoryType,
    required super.categoryUnitId,
    required super.pricingUnitId,
    required super.inventoryUnitId,
    super.attributes,
    super.categoryUnit,
    super.inventoryUnit,
    super.pricingUnit,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data[CategoriesTable.id] ?? 0,
      categoryName: data[CategoriesTable.categoryName],
      categoryNumber: data[CategoriesTable.categoryNumber],
      barcode: data[CategoriesTable.barcode],
      categoryType: CategoryDefineType.of(data[CategoriesTable.categoryType]),
      categoryUnitId: data[CategoriesTable.categoryUnitId],
      pricingUnitId: data[CategoriesTable.pricingUnitId],
      inventoryUnitId: data[CategoriesTable.inventoryUnitId],
    );
  }

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
    UnitEntity? categoryUnit,
    UnitEntity? pricingUnit,
    UnitEntity? inventoryUnit,
    List<CategoryAttributeEntity>? attributes,
  }) {
    return super.copyWith(
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

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) CategoriesTable.id: id,
      CategoriesTable.categoryName: categoryName,
      CategoriesTable.categoryNumber: categoryNumber,
      CategoriesTable.categoryType: categoryType.name,
      CategoriesTable.barcode: barcode,
      CategoriesTable.categoryUnitId: categoryUnitId,
      CategoriesTable.pricingUnitId: pricingUnitId,
      CategoriesTable.inventoryUnitId: inventoryUnitId,
    };
  }
}
