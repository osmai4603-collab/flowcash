import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';

class SubcategoryEntity extends Entity {
  final int id;
  final int mainCategoryId;
  final String catalogName;
  final String? catalogNumber;
  final List<SubcategoryUnitEntity> units;

  const SubcategoryEntity({
    required this.id,
    required this.mainCategoryId,
    required this.catalogName,
    this.catalogNumber,
    this.units = const [],
  });

  @override
  List<Object?> get props => [id, mainCategoryId, catalogName, catalogNumber, units];

  @override
  SubcategoryEntity copyWith({
    int? id,
    int? mainCategoryId,
    String? catalogName,
    String? catalogNumber,
    List<SubcategoryUnitEntity>? units,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      mainCategoryId: mainCategoryId ?? this.mainCategoryId,
      catalogName: catalogName ?? this.catalogName,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      units: units ?? this.units,
    );
  }
}
