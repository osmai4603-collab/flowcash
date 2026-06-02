import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

abstract class MainCategoryUnitDataState {}

class MainCategoryUnitDataInitial extends MainCategoryUnitDataState {}

class MainCategoryUnitDataLoadInProgress extends MainCategoryUnitDataState {}

class MainCategoryUnitDataLoadSuccess extends MainCategoryUnitDataState {
  final MainCategoryEntity category;
  final List<CategoryPropertyEntity> properties;
  final CategoryPropertyEntity? pricingPropertySelected;
  final CategoryPropertyEntity? inventoryPropertySelected;

  MainCategoryUnitDataLoadSuccess({
    required this.category,
    required this.properties,
    required this.pricingPropertySelected,
    required this.inventoryPropertySelected,
  });
}

class MainCategoryUnitDataSaveInProgress extends MainCategoryUnitDataState {}

class MainCategoryUnitDataSaveSuccess extends MainCategoryUnitDataState {
  final bool result;
  MainCategoryUnitDataSaveSuccess(this.result);
}

class MainCategoryUnitDataFailure extends MainCategoryUnitDataState {
  final String message;
  MainCategoryUnitDataFailure(this.message);
}
