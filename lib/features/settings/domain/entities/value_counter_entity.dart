import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:equatable/equatable.dart';

class ValueCounterEntity extends Equatable {
  final int id;
  final ValueCounterType counterType;
  final int count;
  final int counterMax;
  final int incrementValue;
  final String formatValue;

  const ValueCounterEntity({
    this.id = 0,
    this.counterType = ValueCounterType.billNumber,
    this.count = 0,
    this.counterMax = 99999,
    this.incrementValue = 1,
    this.formatValue = '0000',
  });

  @override
  List<Object?> get props => [
    id,
    counterType,
    count,
    counterMax,
    incrementValue,
    formatValue,
  ];

  ValueCounterEntity copyWith({
    int? id,
    ValueCounterType? counterType,
    int? count,
    int? counterMax,
    int? incrementValue,
    String? formatValue,
  }) {
    return ValueCounterEntity(
      id: id ?? this.id,
      counterType: counterType ?? this.counterType,
      count: count ?? this.count,
      counterMax: counterMax ?? this.counterMax,
      incrementValue: incrementValue ?? this.incrementValue,
      formatValue: formatValue ?? this.formatValue,
    );
  }
}
