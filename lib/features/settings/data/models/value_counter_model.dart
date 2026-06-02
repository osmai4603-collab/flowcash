import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../../domain/entities/value_counter_entity.dart';

final class ValueCounterModel extends ValueCounterEntity {
  const ValueCounterModel({
    required super.id,
    required super.counterType,
    required super.count,
    required super.counterMax,
    required super.incrementValue,
    required super.formatValue,
  });

  factory ValueCounterModel.fromMap(Map<String, dynamic> map) {
    final typeName = map[ValuesCounterTable.counterType] as String? ?? '';
    return ValueCounterModel(
      id: map[ValuesCounterTable.id] ?? 0,
      counterType: _typeFromName(typeName),
      count: map[ValuesCounterTable.count] ?? 0,
      counterMax: map[ValuesCounterTable.counterMax] ??99999,
      incrementValue: map[ValuesCounterTable.incrementValue] ??1,
      formatValue: map[ValuesCounterTable.formatValue]?.toString() ?? '0000',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ValuesCounterTable.counterType: counterType.name,
      ValuesCounterTable.count: count,
      ValuesCounterTable.counterMax: counterMax,
      ValuesCounterTable.incrementValue: incrementValue,
      ValuesCounterTable.formatValue: formatValue,
    };
  }

  @override
  ValueCounterModel copyWith({
    int? id,
    ValueCounterType? counterType,
    int? count,
    int? counterMax,
    int? incrementValue,
    String? formatValue,
  }) {
    return ValueCounterModel(
      id: id ?? this.id,
      counterType: counterType ?? this.counterType,
      count: count ?? this.count,
      counterMax: counterMax ?? this.counterMax,
      incrementValue: incrementValue ?? this.incrementValue,
      formatValue: formatValue ?? this.formatValue,
    );
  }

  static ValueCounterType _typeFromName(String name) {
    try {
      return ValueCounterType.of(name);
    } catch (_) {
      return ValueCounterType.billNumber;
    }
  }
}
