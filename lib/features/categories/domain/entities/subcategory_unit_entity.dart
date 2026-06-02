import 'package:flowcash/core/entities/entity.dart';

class SubcategoryUnitEntity extends Entity {
  final int id;
  final int subcategoryId;
  final int unitId;
  final int propertyId;
  final String? unitName;

  const SubcategoryUnitEntity({
    required this.id,
    required this.subcategoryId,
    required this.unitId,
    required this.propertyId,
    this.unitName,
  });

  @override
  List<Object?> get props => [id, subcategoryId, unitId];


  @override
  SubcategoryUnitEntity copyWith({
    int? id,
    int? subcategoryId,
    int? unitId,
    int? propertyId,
    String? unitName,
  }) {
    return SubcategoryUnitEntity(
      id: id ?? this.id,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      unitId: unitId ?? this.unitId,
      propertyId: propertyId ?? this.propertyId,
      unitName: unitName ?? this.unitName,
    );
  }
}
