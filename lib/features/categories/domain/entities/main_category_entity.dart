import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

class MainCategoryEntity extends Entity {
  final int id;
  final String name;
  final CategoryDefineType type;
  final int categoryUnitId;
  final UnitEntity? categoryUnit;
  final List<CategoryPropertyEntity> properties;

  const MainCategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryUnitId,
    this.categoryUnit,
    this.properties = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    properties,
    categoryUnitId,
    categoryUnit,
  ];

  @override
  MainCategoryEntity copyWith({
    int? id,
    String? name,
    CategoryDefineType? type,
    List<CategoryPropertyEntity>? properties,
    int? categoryUnitId,
    UnitEntity? categoryUnit,
  }) {
    return MainCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      categoryUnitId: categoryUnitId ?? this.categoryUnitId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
    );
  }
}
