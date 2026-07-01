import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/models/model.dart';

final class MainCategoryModel extends MainCategoryEntity implements Model {
   MainCategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.categoryUnitId,
    super.categoryUnit,
    super.properties = const [],
  });

  factory MainCategoryModel.fromMap(Map<String, dynamic> map) {
    return MainCategoryModel(
      id: map[MainCategoriesTable().id] as int,
      name: map[MainCategoriesTable().categoryName] as String? ?? '',
      type: CategoryDefineType.of(
        map[MainCategoriesTable().categoryType] as String? ?? 'commodities',
      ),
      categoryUnitId: map[MainCategoriesTable().categoryUnitId] as int? ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      MainCategoriesTable().id: id,
      MainCategoriesTable().categoryName: name,
      MainCategoriesTable().categoryType: type.name,
      MainCategoriesTable().categoryUnitId: categoryUnitId,
    };
  }

  @override
  MainCategoryModel copyWith({
    int? id,
    String? name,
    CategoryDefineType? type,
    List<CategoryPropertyEntity>? properties,
    int? categoryUnitId,
    UnitEntity? categoryUnit,
  }) {
    return MainCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      categoryUnitId: categoryUnitId ?? this.categoryUnitId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
    );
  }
}
