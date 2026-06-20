import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';

final class CategoryAttributeModel extends CategoryAttributeEntity {
  const CategoryAttributeModel({
    required super.id,
    required super.subcategoryUnitId,
    required super.categoryId,
  });

  factory CategoryAttributeModel.fromMap(Map<String, dynamic> map) {
    return CategoryAttributeModel(
      id: map[CategoriesAttributesTable.id] as int,
      subcategoryUnitId:
          map[CategoriesAttributesTable.subcategoryUnitId] as int,
      categoryId: map[CategoriesAttributesTable.categoryId] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CategoriesAttributesTable.id: id,
      CategoriesAttributesTable.subcategoryUnitId: subcategoryUnitId,
      CategoriesAttributesTable.categoryId: categoryId,
    };
  }

  @override
  CategoryAttributeModel copyWith({
    int? id,
    int? subcategoryUnitId,
    int? categoryId,
  }) {
    return CategoryAttributeModel(
      id: id ?? this.id,
      subcategoryUnitId: subcategoryUnitId ?? this.subcategoryUnitId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
