import 'package:flowcash/core/entities/entity.dart';

class CategoryAttributeEntity extends Entity {
  final int id;
  final int subcategoryUnitId;
  final int categoryId;

  const CategoryAttributeEntity({
    required this.id,
    required this.subcategoryUnitId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, subcategoryUnitId, categoryId];

  CategoryAttributeEntity copyWith({
    int? id,
    int? subcategoryUnitId,
    int? categoryId,
  }) {
    return CategoryAttributeEntity(
      id: id ?? this.id,
      subcategoryUnitId: subcategoryUnitId ?? this.subcategoryUnitId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
