import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/features/categories/domain/entities/measurable_unit.dart';

class UnitEntity extends Entity {
  final int id;
  final String unitName;
  final int? propertyId;
  final UnitType unitType;
  final MeasurableUnit measurement;

  const UnitEntity({
    required this.id,
    required this.unitName,
    this.propertyId,
    required this.unitType,
    required this.measurement,
  });

  double get length => measurement.length;
  double get width => measurement.width;
  double get thickness => measurement.thickness;

  UnitEntity.piece({required int id, required int count, String unitName = 'حبة'})
    : this(
        id: id,
        unitName: '$count$unitName',
        unitType: UnitType.piece,
        measurement: PieceMeasurableUnit(count: count.toDouble()),
      );

  UnitEntity.squareMeter({
    required int id,
    required double length,
    required double width,
  }) : this(
         id: id,
         unitName: '${AppMoneyFormatter.formatDouble(width * length)}متر مربع',
         unitType: UnitType.squareMeter,
         measurement: AreaMeasurableUnit(length: length, width: width),
       );

  UnitEntity.squareMeterWidthStatic({
    required int id,
    required double width,
  }) : this(
         id: id,
         unitName: '${AppMoneyFormatter.formatDouble(width)}متر',
         unitType: UnitType.squareMeterWidthStatic,
         measurement: AreaMeasurableUnit(length: 1, width: width),
       );

  UnitEntity.squareMeterStatic({
    required int id,
    required double length,
    required double width,
  }) : this(
         id: id,
         unitName:
             '${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}',
         unitType: UnitType.squareMeterStatic,
         measurement: AreaMeasurableUnit(length: length, width: width),
       );

  UnitEntity.cubitMeter({
    required int id,
    required double length,
    required double width,
    required double thickness,
  }) : this(
         id: id,
         unitName:
             '${AppMoneyFormatter.formatDouble(thickness * 100)}x${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}',
         unitType: UnitType.cubitMeter,
         measurement: VolumeMeasurableUnit(
           length: length,
           width: width,
           thickness: thickness,
         ),
       );

  UnitEntity.linearMeter({
    required int id,
    int? propertyId,
    required double length,
    required String unitName,
  }) : this(
         id: id,
         unitName: unitName,
         unitType: UnitType.linearMeter,
         measurement: LinearMeasurableUnit(length),
       );

  UnitEntity.weight({
    required int id,
    required double weight,
    required String unitName,
  }) : this(
         id: id,
         unitName: '${AppMoneyFormatter.formatDouble(weight)}$unitName',
         unitType: UnitType.weight,
         measurement: WeightMeasurableUnit(weight),
       );

  const UnitEntity.text({required int id, required String textName})
    : this(
        id: id,
        unitName: textName,
        unitType: UnitType.model,
        measurement: const VolumeMeasurableUnit(length: 0.0, width: 0.0, thickness: 0.0),
      );

  const UnitEntity.basicUnit({required int id, required String unitName, required UnitType unitType})
      : this(
    id: id,
    unitName: unitName,
    unitType: unitType,
    measurement: const VolumeMeasurableUnit(length: 0.0, width: 0.0, thickness: 0.0),
  );

  @override
  List<Object?> get props => [id, unitName, measurement, unitType];

  @override
  UnitEntity copyWith({
    int? id,
    String? unitName,
    double? length,
    double? width,
    double? thickness,
    UnitType? unitType,
    MeasurableUnit? measurement,
  }) {
    return UnitEntity(
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

  bool get isMeasurable => unitType.isMeasurable;

  bool get isBasicUnit {
    return unitType.isBasic && length == 0.0 && width == 0.0 && thickness == 0.0;
  }

  double get countUnits => measurement.countUnits;

  double toSquareMeter(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.piece:
        return countUnits * unit.length * unit.width;
      case UnitType.linearMeter:
        return countUnits * width;
      case UnitType.squareMeterWidthStatic:
        return width;
      case UnitType.cubitMeter:
        return countUnits / thickness;
      default:
        return countUnits;
    }
  }

  double toSquareMeterStatic(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.model:
        return countUnits;
      case UnitType.piece:
        return countUnits * unit.length * unit.width;
      case UnitType.weight:
        return countUnits;
      case UnitType.linearMeter:
        return countUnits * width;
      case UnitType.squareMeter:
        return countUnits;
      case UnitType.squareMeterStatic:
        return countUnits;
      case UnitType.squareMeterWidthStatic:
        return width;
      case UnitType.cubitMeter:
        return countUnits / thickness;
      default:
        return countUnits;
    }
  }

  double toSquareMeterWidthStatic(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.squareMeterWidthStatic:
        return countUnits;
      case UnitType.model:
      case UnitType.piece:
      case UnitType.weight:
      case UnitType.linearMeter:
      case UnitType.squareMeter:
      case UnitType.squareMeterStatic:
      case UnitType.cubitMeter:
        return countUnits;
      default:
        return countUnits;
    }
  }

  double toCubitMeter(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.model:
        return countUnits;
      case UnitType.piece:
        return countUnits * unit.countUnits;
      case UnitType.weight:
        return countUnits;
      case UnitType.linearMeter:
        return countUnits * width * thickness;
      case UnitType.squareMeter:
        return countUnits * thickness;
      case UnitType.squareMeterStatic:
        return countUnits * thickness;
      case UnitType.squareMeterWidthStatic:
        return countUnits * thickness;
      case UnitType.cubitMeter:
        return countUnits;
      default:
        return countUnits;
    }
  }

  double toLinearMeter(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.model:
        return countUnits;
      case UnitType.piece:
        return countUnits * unit.length;
      case UnitType.weight:
        return countUnits;
      case UnitType.linearMeter:
        return countUnits;
      case UnitType.squareMeter:
        return countUnits / width;
      case UnitType.squareMeterStatic:
        return countUnits / width;
      case UnitType.squareMeterWidthStatic:
        return countUnits / width;
      case UnitType.cubitMeter:
        return countUnits / (length * width);
      default:
        return countUnits;
    }
  }

  double toWeight(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.model:
        return countUnits;
      case UnitType.piece:
        return countUnits * unit.length;
      case UnitType.weight:
        return countUnits;
      case UnitType.linearMeter:
        return countUnits;
      case UnitType.squareMeter:
        return countUnits * unit.length;
      case UnitType.squareMeterStatic:
        return countUnits;
      case UnitType.squareMeterWidthStatic:
        return countUnits * unit.length;
      case UnitType.cubitMeter:
        return countUnits;
      default:
        return countUnits;
    }
  }

  double toPiece(double countUnits, UnitEntity unit) {
    switch (unitType) {
      case UnitType.model:
        return countUnits;
      case UnitType.piece:
        return countUnits;
      case UnitType.weight:
        return countUnits / this.countUnits;
      case UnitType.linearMeter:
        return countUnits / this.countUnits;
      case UnitType.squareMeter:
        return countUnits / (length * width);
      case UnitType.squareMeterStatic:
        return countUnits / (length * width);
      case UnitType.squareMeterWidthStatic:
        return countUnits;
      case UnitType.cubitMeter:
        return countUnits / this.countUnits;
      default:
        return countUnits;
    }
  }

  String get categoryName {
    switch (unitType) {
      case UnitType.model:
      case UnitType.piece:
        return unitType.unitName;
      case UnitType.weight:
      case UnitType.linearMeter:
        return '${AppMoneyFormatter.formatDouble(length)}$unitName';
      case UnitType.squareMeter:
        return '';
      case UnitType.squareMeterStatic:
        return '${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}';
      case UnitType.squareMeterWidthStatic:
        return '${AppMoneyFormatter.formatDouble(width)}${unitType.displayName()}';
      case UnitType.cubitMeter:
        return '${AppMoneyFormatter.formatDouble(thickness * 100)}x${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}';
      default:
        return unitType.unitName;
    }
  }

  String getCategoryName({String? containerName, bool printUnitName = false}) {
    switch (unitType) {
      case UnitType.model:
      case UnitType.piece:
        return unitName;
      case UnitType.weight:
      case UnitType.linearMeter:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(length)}$unitName';
      case UnitType.squareMeter:
      case UnitType.squareMeterStatic:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}${printUnitName ? ' ${unitType.unitName}' : ''}';
      case UnitType.squareMeterWidthStatic:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(width)}${unitType.typeName}';
      case UnitType.cubitMeter:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(thickness * 100)}x${AppMoneyFormatter.formatDouble(width * 100)}x${AppMoneyFormatter.formatDouble(length * 100)}${printUnitName ? ' ${unitType.displayName()}' : ''}';
      default:
        return unitType.unitName;
    }
  }

  String getStructName({
    String? containerName,
    bool printUnitName = true,
    double length = 1,
  }) {
    switch (unitType) {
      case UnitType.model:
      case UnitType.piece:
        return unitName;
      case UnitType.weight:
      case UnitType.linearMeter:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(length)}$unitName';
      case UnitType.squareMeter:
      case UnitType.squareMeterStatic:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(width)}x${AppMoneyFormatter.formatDouble(length)}${printUnitName ? ' ${unitType.displayName()}' : ''}';
      case UnitType.squareMeterWidthStatic:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(width)}x${AppMoneyFormatter.formatDouble(length)}${printUnitName ? ' ${unitType.displayName()}' : ''}';
      case UnitType.cubitMeter:
        return '${containerName != null ? '$containerName = ' : ''}${AppMoneyFormatter.formatDouble(thickness)}x${AppMoneyFormatter.formatDouble(width)}x${AppMoneyFormatter.formatDouble(length)}${printUnitName ? ' ${unitType.displayName()}' : ''}';
      default:
        return unitType.unitName;
    }
  }

}
