import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';

final class SimpleCategoryModel extends SimpleCategoryEntity {
  const SimpleCategoryModel({
    required super.id,
    required super.categoryName,
    required super.unitName,
    required super.unitType,
  });

  factory SimpleCategoryModel.fromMap(Map<String, dynamic> map) {
    return SimpleCategoryModel(
      id: map[MainCategoriesTable().id] as int,
      categoryName: map[MainCategoriesTable().categoryName] as String? ?? '',
      unitName: map[MainCategoriesTable().unitName] as String? ?? '',
      unitType: UnitType.of(
        map[MainCategoriesTable().unitType] as String? ?? 'piece',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      MainCategoriesTable().id: id,
      MainCategoriesTable().categoryName: categoryName,
      MainCategoriesTable().unitName: unitName,
      MainCategoriesTable().unitType: unitType.name,
    };
  }

  @override
  SimpleCategoryModel copyWith({
    int? id,
    String? categoryName,
    String? unitName,
    UnitType? unitType,
  }) {
    return SimpleCategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
    );
  }
}
