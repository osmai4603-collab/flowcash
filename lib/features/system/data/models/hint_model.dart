import 'package:flowcash/features/system/domain/entities/hint_entity.dart';
import 'package:flowcash/core/tables/hints_table.dart';

final class HintModel extends HintEntity {
  const HintModel({
    required super.id,
    required super.hintName,
    required super.hintType,
  });

  factory HintModel.fromMap(Map<String, dynamic> map) {
    return HintModel(
      id: map[HintsTable.id] as int,
      hintName: map[HintsTable.hintName] as String? ?? '',
      hintType: map[HintsTable.hintType] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      HintsTable.id: id,
      HintsTable.hintName: hintName,
      HintsTable.hintType: hintType,
    };
  }

  @override
  HintModel copyWith({int? id, String? hintName, String? hintType}) {
    return HintModel(
      id: id ?? this.id,
      hintName: hintName ?? this.hintName,
      hintType: hintType ?? this.hintType,
    );
  }
}
