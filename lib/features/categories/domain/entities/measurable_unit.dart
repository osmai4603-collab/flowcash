import 'package:equatable/equatable.dart';

abstract class MeasurableUnit extends Equatable {
  final double length;
  final double width;
  final double thickness;

  const MeasurableUnit({
    this.length = 0.0,
    this.width = 0.0,
    this.thickness = 0.0,
  });

  double get countUnits => length * width * thickness;

  @override
  List<Object?> get props => [length, width, thickness];
}

class PieceMeasurableUnit extends MeasurableUnit {
  const PieceMeasurableUnit({double count = 0.0})
      : super(length: count, width: 1.0, thickness: 1.0);
}

class WeightMeasurableUnit extends MeasurableUnit {
  const WeightMeasurableUnit(double weight)
      : super(length: weight, width: 1.0, thickness: 1.0);
}

class LinearMeasurableUnit extends MeasurableUnit {
  const LinearMeasurableUnit(double length)
      : super(length: length, width: 1.0, thickness: 1.0);
}

class AreaMeasurableUnit extends MeasurableUnit {
  const AreaMeasurableUnit({required double length, required double width})
      : super(length: length, width: width, thickness: 1.0);
}

class VolumeMeasurableUnit extends MeasurableUnit {
  const VolumeMeasurableUnit({
    required double length,
    required double width,
    required double thickness,
  }) : super(length: length, width: width, thickness: thickness);
}

class ModelMeasurableUnit extends MeasurableUnit {
  const ModelMeasurableUnit() : super(length: 1.0, width: 1.0, thickness: 1.0);
}
