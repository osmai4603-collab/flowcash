import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

class SimpleCategoryEntity extends Entity {
  final int id;
  final String categoryName;
  final String unitName;
  final UnitType unitType;

  const SimpleCategoryEntity({
    required this.id,
    required this.categoryName,
    required this.unitName,
    required this.unitType,
  });

  @override
  List<Object?> get props => [id, categoryName, unitName, unitType];

  @override
  SimpleCategoryEntity copyWith({
    int? id,
    String? categoryName,
    String? unitName,
    UnitType? unitType,
  }) {
    return SimpleCategoryEntity(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
    );
  }
}
