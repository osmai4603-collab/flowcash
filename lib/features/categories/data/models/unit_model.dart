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
    final table = UnitsTable();
    final unitType = UnitType.of(map[table.unitType] as String);
    return UnitModel(
      id: map[table.id] as int,
      unitName: map[table.unitName],
      unitType: unitType,
      measurement: MeasurableUnit.fromValues(
        unitType: unitType,
        length: ((map[table.length]) as num).toDouble(),
        width: ((map[table.width]) as num).toDouble(),
        thickness: ((map[table.thickness]) as num).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    final table = UnitsTable();
    return {
      if (id > 0) table.id: id,
      table.unitName: unitName,
      table.length: length,
      table.width: width,
      table.thickness: thickness,
      table.unitType: unitType.name,
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
