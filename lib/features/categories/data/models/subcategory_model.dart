import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';

final class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.mainCategoryId,
    required super.catalogName,
    super.catalogNumber,
    super.units = const [],
  });

  factory SubcategoryModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryModel(
      id: map[SubcategoriesTable().id] as int,
      mainCategoryId: map[SubcategoriesTable().mainCategoryId] as int,
      catalogName: map[SubcategoriesTable().catalogName] as String? ?? '',
      catalogNumber: map[SubcategoriesTable().catalogNumber] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SubcategoriesTable().id: id,
      SubcategoriesTable().mainCategoryId: mainCategoryId,
      SubcategoriesTable().catalogName: catalogName,
      SubcategoriesTable().catalogNumber: catalogNumber,
    };
  }

  @override
  SubcategoryModel copyWith({
    int? id,
    int? mainCategoryId,
    String? catalogName,
    String? catalogNumber,
    List<SubcategoryUnitEntity>? units,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      mainCategoryId: mainCategoryId ?? this.mainCategoryId,
      catalogName: catalogName ?? this.catalogName,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      units: units ?? this.units,
    );
  }

  static SubcategoryModel fromEntity(SubcategoryEntity entity) {
    return SubcategoryModel(
      id: entity.id,
      mainCategoryId: entity.mainCategoryId,
      catalogName: entity.catalogName,
      catalogNumber: entity.catalogNumber,
      units: entity.units,
    );
  }
}
