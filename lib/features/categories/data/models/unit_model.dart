import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/tables/units_table.dart';

final class UnitModel extends UnitEntity {
  const UnitModel({
    required super.id,
    required super.unitName,
    super.propertyId,
    super.length = 0.0,
    super.width = 0.0,
    super.thickness = 0.0,
    required super.unitType,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map[UnitsTable.id] as int,
      unitName: (map[UnitsTable.unitName] as String?) ?? "",
      length: ((map[UnitsTable.length]) as num).toDouble(),
      width: ((map[UnitsTable.width]) as num).toDouble(),
      thickness: ((map[UnitsTable.thickness]) as num).toDouble(),
      unitType: UnitType.of(map[UnitsTable.unitType] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) UnitsTable.id: id,
      UnitsTable.unitName: unitName,
      UnitsTable.length: length,
      UnitsTable.width: width,
      UnitsTable.thickness: thickness,
      UnitsTable.unitType: unitType.name,
    };
  }

  @override
  UnitModel copyWith({
    int? id,
    String? unitName,
    double? length,
    double? width,
    double? thickness,
    UnitType? unitType,
  }) {
    return UnitModel(
      id: id ?? this.id,
      unitName: unitName ?? this.unitName,
      length: length ?? this.length,
      width: width ?? this.width,
      thickness: thickness ?? this.thickness,
      unitType: unitType ?? this.unitType,
    );
  }
}
