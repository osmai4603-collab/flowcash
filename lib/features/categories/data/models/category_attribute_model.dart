import 'package:flowcash/features/categories/domain/entities/category_attribute_entity.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/models/model.dart';

final class CategoryAttributeModel extends CategoryAttributeEntity implements Model {
  const CategoryAttributeModel({
    required super.id,
    required super.subcategoryUnitId,
    required super.categoryId,
  });

  factory CategoryAttributeModel.fromMap(Map<String, dynamic> map) {
    return CategoryAttributeModel(
      id: map[CategoriesAttributesTable().id] as int,
      subcategoryUnitId:
          map[CategoriesAttributesTable().subcategoryUnitId] as int,
      categoryId: map[CategoriesAttributesTable().categoryId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if(id > 0) CategoriesAttributesTable().id: id,
      CategoriesAttributesTable().subcategoryUnitId: subcategoryUnitId,
      CategoriesAttributesTable().categoryId: categoryId,
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

  static CategoryAttributeModel fromEntity(CategoryAttributeEntity entity) {
    return CategoryAttributeModel(
      id: entity.id,
      categoryId: entity.categoryId,
      subcategoryUnitId: entity.subcategoryUnitId,
    );
  }
}
