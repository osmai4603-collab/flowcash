import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';

final class SubcategoryUnitModel extends SubcategoryUnitEntity {
  const SubcategoryUnitModel({
    required super.id,
    required super.subcategoryId,
    required super.unitId,
    required super.propertyId,
    super.unitName,
  });

  factory SubcategoryUnitModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryUnitModel(
      id: map[SubcategoriesUnitsTable.id] as int,
      subcategoryId: map[SubcategoriesUnitsTable.subcategoryId] as int,
      unitId: map[SubcategoriesUnitsTable.unitId] as int,
      propertyId: map[SubcategoriesUnitsTable.propertyId] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SubcategoriesUnitsTable.id: id,
      SubcategoriesUnitsTable.subcategoryId: subcategoryId,
      SubcategoriesUnitsTable.unitId: unitId,
      SubcategoriesUnitsTable.propertyId: propertyId,
    };
  }

  @override
  SubcategoryUnitModel copyWith({
    int? id,
    int? subcategoryId,
    int? unitId,
    int? propertyId,
    String? unitName,
  }) {
    return SubcategoryUnitModel(
      id: id ?? this.id,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      unitId: unitId ?? this.unitId,
      propertyId: propertyId ?? this.propertyId,
      unitName: unitName ?? this.unitName,
    );
  }
}
