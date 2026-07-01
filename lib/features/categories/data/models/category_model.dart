import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/models/model.dart';

final class CategoryModel extends CategoryEntity implements Model {
  const CategoryModel({
    required super.id,
    required super.categoryName,
    required super.barcode,
    required super.categoryNumber,
    required super.categoryType,
    required super.categoryUnitId,
    required super.pricingUnitId,
    required super.inventoryUnitId,
    super.subcategoryId,
    super.attributes,
    super.categoryUnit,
    super.inventoryUnit,
    super.pricingUnit,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data[CategoriesTable().id] ?? 0,
      categoryName: data[CategoriesTable().categoryName],
      categoryNumber: data[CategoriesTable().categoryNumber],
      barcode: data[CategoriesTable().barcode],
      categoryType: CategoryDefineType.of(data[CategoriesTable().categoryType]),
      categoryUnitId: data[CategoriesTable().categoryUnitId],
      pricingUnitId: data[CategoriesTable().pricingUnitId],
      inventoryUnitId: data[CategoriesTable().inventoryUnitId],
      subcategoryId: data[CategoriesTable().subcategoryId],
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
    int? subcategoryId,
    UnitEntity? categoryUnit,
    UnitEntity? pricingUnit,
    UnitEntity? inventoryUnit,
    SubcategoryEntity? subcategory,
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
      subcategoryId: subcategoryId ?? this.subcategoryId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      inventoryUnit: inventoryUnit ?? this.inventoryUnit,
      subcategory: subcategory ?? this.subcategory,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) CategoriesTable().id: id,
      CategoriesTable().categoryName: categoryName,
      CategoriesTable().categoryNumber: categoryNumber,
      CategoriesTable().categoryType: categoryType.name,
      CategoriesTable().barcode: barcode,
      CategoriesTable().categoryUnitId: categoryUnitId,
      CategoriesTable().pricingUnitId: pricingUnitId,
      CategoriesTable().inventoryUnitId: inventoryUnitId,
      CategoriesTable().subcategoryId: subcategoryId,
    };
  }
}
