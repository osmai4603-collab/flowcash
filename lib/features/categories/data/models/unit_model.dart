import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/features/categories/domain/entities/measurable_unit.dart';

final class UnitModel extends UnitEntity {
  const UnitModel({
    required super.id,
    required super.unitName,
    super.propertyId,
    required super.unitType,
    required super.measurement,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    final unitType = UnitType.of(map[UnitsTable().unitType] as String);
    return UnitModel(
      id: map[UnitsTable().id] as int,
      unitName: (map[UnitsTable().unitName] as String?) ?? "",
      unitType: unitType,
      measurement: MeasurableUnit.fromValues(
        unitType: unitType,
        length: ((map[UnitsTable().length]) as num).toDouble(),
        width: ((map[UnitsTable().width]) as num).toDouble(),
        thickness: ((map[UnitsTable().thickness]) as num).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) UnitsTable().id: id,
      UnitsTable().unitName: unitName,
      UnitsTable().length: length,
      UnitsTable().width: width,
      UnitsTable().thickness: thickness,
      UnitsTable().unitType: unitType.name,
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
    MeasurableUnit? measurement,
  }) {
    return UnitModel(
      id: id ?? this.id,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
      measurement:
          measurement ??
          this.measurement.copyWith(
            length: length,
            width: width,
            thickness: thickness,
          ),
    );
  }
}
