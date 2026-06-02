import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';

class MainCategoryEntity extends Entity {
  final int id;
  final String name;
  final CategoryDefineType type;
  final String unitName;
  final UnitType unitType;
  final List<CategoryPropertyEntity> properties;

  const MainCategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.unitName,
    required this.unitType,
    this.properties = const [],
  });

  @override
  List<Object?> get props => [id, name, type, properties, unitName];

  @override
  MainCategoryEntity copyWith({
    int? id,
    String? name,
    CategoryDefineType? type,
    List<CategoryPropertyEntity>? properties,
    String? unitName,
    UnitType? unitType,
  }) {
    return MainCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
    );
  }
}
