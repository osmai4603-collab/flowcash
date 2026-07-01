import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/models/model.dart';

final class SimpleCategoryModel extends SimpleCategoryEntity implements Model {
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
      unitName: map['unit_name'] as String? ?? '',
      unitType: UnitType.of(map['unit_type'] as String? ?? 'piece'),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      MainCategoriesTable().id: id,
      MainCategoriesTable().categoryName: categoryName,
      'unit_name': unitName,
      'unit_type': unitType.name,
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
