import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

abstract class MeasurableUnit extends Equatable {
  final double length;
  final double width;
  final double thickness;

  const MeasurableUnit({
    this.length = 0.0,
    this.width = 0.0,
    this.thickness = 0.0,
  });

  factory MeasurableUnit.fromValues({
    required UnitType unitType,
    double length = 0.0,
    double width = 0.0,
    double thickness = 0.0,
  }) {
    if (unitType.isPiece) return PieceMeasurableUnit(count: length);
    if (unitType.isWeight) return WeightMeasurableUnit(length);
    if (unitType.isLinearMeter) return LinearMeasurableUnit(length);
    if (unitType.hasSquareMeter) {
      return AreaMeasurableUnit(length: length, width: width);
    }
    if (unitType.isCubitMeter) {
      return VolumeMeasurableUnit(
        length: length,
        width: width,
        thickness: thickness,
      );
    }
    return const ModelMeasurableUnit();
  }

  double get countUnits => length * width * thickness;

  @override
  List<Object?> get props => [length, width, thickness];

  MeasurableUnit copyWith({double? length, double? width, double? thickness});
}

class PieceMeasurableUnit extends MeasurableUnit {
  const PieceMeasurableUnit({double count = 0.0})
    : super(length: count, width: 1.0, thickness: 1.0);

  @override
  PieceMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return PieceMeasurableUnit(count: length ?? this.length);
  }
}

class WeightMeasurableUnit extends MeasurableUnit {
  const WeightMeasurableUnit(double weight)
    : super(length: weight, width: 1.0, thickness: 1.0);

  @override
  WeightMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return WeightMeasurableUnit(length ?? this.length);
  }
}

class LinearMeasurableUnit extends MeasurableUnit {
  const LinearMeasurableUnit(double length)
    : super(length: length, width: 1.0, thickness: 1.0);

  @override
  LinearMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return LinearMeasurableUnit(length ?? this.length);
  }
}

class AreaMeasurableUnit extends MeasurableUnit {
  const AreaMeasurableUnit({required double length, required double width})
    : super(length: length, width: width, thickness: 1.0);

  @override
  AreaMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return AreaMeasurableUnit(
      length: length ?? this.length,
      width: width ?? this.width,
    );
  }
}

class VolumeMeasurableUnit extends MeasurableUnit {
  const VolumeMeasurableUnit({
    required double length,
    required double width,
    required double thickness,
  }) : super(length: length, width: width, thickness: thickness);

  @override
  VolumeMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return VolumeMeasurableUnit(
      length: length ?? this.length,
      width: width ?? this.width,
      thickness: thickness ?? this.thickness,
    );
  }
}

class ModelMeasurableUnit extends MeasurableUnit {
  const ModelMeasurableUnit() : super(length: 1.0, width: 1.0, thickness: 1.0);

  @override
  ModelMeasurableUnit copyWith({
    double? length,
    double? width,
    double? thickness,
  }) {
    return const ModelMeasurableUnit();
  }
}
