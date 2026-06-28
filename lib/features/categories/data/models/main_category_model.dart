import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';

final class MainCategoryModel extends MainCategoryEntity {
  const MainCategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.unitName,
    required super.unitType,
    super.properties = const [],
  });

  factory MainCategoryModel.fromMap(Map<String, dynamic> map) {
    return MainCategoryModel(
      id: map[MainCategoriesTable().id] as int,
      name: map[MainCategoriesTable().categoryName] as String? ?? '',
      type: CategoryDefineType.of(
        map[MainCategoriesTable().categoryType] as String? ?? 'commodities',
      ),
      unitName: map[MainCategoriesTable().unitName] as String? ?? '',
      unitType: UnitType.of(
        map[MainCategoriesTable().unitType] as String? ?? 'piece',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      MainCategoriesTable().id: id,
      MainCategoriesTable().categoryName: name,
      MainCategoriesTable().categoryType: type.name,
      MainCategoriesTable().unitName: unitName,
      MainCategoriesTable().unitType: unitType.name,
    };
  }

  @override
  MainCategoryModel copyWith({
    int? id,
    String? name,
    CategoryDefineType? type,
    List<CategoryPropertyEntity>? properties,
    String? unitName,
    UnitType? unitType,
  }) {
    return MainCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
    );
  }
}
