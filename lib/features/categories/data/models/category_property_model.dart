import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';

final class CategoryPropertyModel extends CategoryPropertyEntity {
  const CategoryPropertyModel({
    required super.id,
    required super.mainCategoryId,
    required super.propertyName,
    required super.unitType,
    required super.isSingle,
    required super.isCategoryUnit,
    required super.isPricingUnit,
    required super.isInventoryUnit,
  });

  factory CategoryPropertyModel.fromMap(Map<String, dynamic> map) {
    return CategoryPropertyModel(
      id: map[CategoryPropertiesTable().id] as int,
      mainCategoryId: map[CategoryPropertiesTable().mainCategoryId] as int,
      propertyName:
          map[CategoryPropertiesTable().propertyName] as String? ?? '',
      unitType: UnitType.of(
        map[CategoryPropertiesTable().unitType] as String? ?? 'piece',
      ),
      isSingle:
          map[CategoryPropertiesTable().isSingle] == 1 ||
          map[CategoryPropertiesTable().isSingle] == true,
      isCategoryUnit:
          map[CategoryPropertiesTable().isCategoryUnit] == 1 ||
          map[CategoryPropertiesTable().isCategoryUnit] == true,
      isPricingUnit:
          map[CategoryPropertiesTable().isPricingUnit] == 1 ||
          map[CategoryPropertiesTable().isPricingUnit] == true,
      isInventoryUnit:
          map[CategoryPropertiesTable().isInventoryUnit] == 1 ||
          map[CategoryPropertiesTable().isInventoryUnit] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CategoryPropertiesTable().id: id,
      CategoryPropertiesTable().mainCategoryId: mainCategoryId,
      CategoryPropertiesTable().propertyName: propertyName,
      CategoryPropertiesTable().unitType: unitType.name,
      CategoryPropertiesTable().isSingle: isSingle ? 1 : 0,
      CategoryPropertiesTable().isCategoryUnit: isCategoryUnit ? 1 : 0,
      CategoryPropertiesTable().isPricingUnit: isPricingUnit ? 1 : 0,
      CategoryPropertiesTable().isInventoryUnit: isInventoryUnit ? 1 : 0,
    };
  }

  @override
  CategoryPropertyModel copyWith({
    int? id,
    int? mainCategoryId,
    String? propertyName,
    UnitType? unitType,
    bool? isSingle,
    bool? isCategoryUnit,
    bool? isPricingUnit,
    bool? isInventoryUnit,
  }) {
    return CategoryPropertyModel(
      id: id ?? this.id,
      mainCategoryId: mainCategoryId ?? this.mainCategoryId,
      propertyName: propertyName ?? this.propertyName,
      unitType: unitType ?? this.unitType,
      isSingle: isSingle ?? this.isSingle,
      isCategoryUnit: isCategoryUnit ?? this.isCategoryUnit,
      isPricingUnit: isPricingUnit ?? this.isPricingUnit,
      isInventoryUnit: isInventoryUnit ?? this.isInventoryUnit,
    );
  }

  static CategoryPropertyModel fromEntity(CategoryPropertyEntity entity) {
    return CategoryPropertyModel(
      id: entity.id,
      mainCategoryId: entity.mainCategoryId,
      propertyName: entity.propertyName,
      unitType: entity.unitType,
      isSingle: entity.isSingle,
      isCategoryUnit: entity.isCategoryUnit,
      isPricingUnit: entity.isPricingUnit,
      isInventoryUnit: entity.isInventoryUnit,
    );
  }
}
