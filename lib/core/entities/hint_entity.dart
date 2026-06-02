import 'package:flowcash/core/entities/entity.dart';

/// كينونة التلميح المالي (HintEntity) المستخدمة لتسهيل إدخال الملاحظات المتكررة.
class HintEntity extends Entity {
  final int id;
  final String hintName;
  final String hintType;

  const HintEntity({
    required this.id,
    required this.hintName,
    required this.hintType,
  });

  @override
  List<Object?> get props => [id, hintName, hintType];

  HintEntity copyWith({
    int? id,
    String? hintName,
    String? hintType,
  }) {
    return HintEntity(
      id: id ?? this.id,
      hintName: hintName ?? this.hintName,
      hintType: hintType ?? this.hintType,
    );
  }
}
