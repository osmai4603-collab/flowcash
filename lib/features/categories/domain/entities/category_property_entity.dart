import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class CategoryPropertyEntity extends Entity {
  final int id;
  final int mainCategoryId;
  final String propertyName;
  final UnitType unitType;
  final bool isSingle;
  final bool isCategoryUnit;
  final bool isPricingUnit;
  final bool isInventoryUnit;

  const CategoryPropertyEntity({
    required this.id,
    required this.mainCategoryId,
    required this.propertyName,
    required this.unitType,
    required this.isSingle,
    required this.isCategoryUnit,
    required this.isPricingUnit,
    required this.isInventoryUnit,
  });

  @override
  List<Object?> get props => [
    id,
    mainCategoryId,
    propertyName,
    unitType,
    isSingle,
    isCategoryUnit,
    isPricingUnit,
    isInventoryUnit,
  ];

  CategoryPropertyEntity copyWith({
    int? id,
    int? mainCategoryId,
    String? propertyName,
    UnitType? unitType,
    bool? isSingle,
    bool? isCategoryUnit,
    bool? isPricingUnit,
    bool? isInventoryUnit,
  }) {
    return CategoryPropertyEntity(
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
}
