import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

abstract class MainCategoryUnitDataEvent {}

class InitMainCategoryUnitDataEvent extends MainCategoryUnitDataEvent {
  final MainCategoryEntity mainCategory;
  InitMainCategoryUnitDataEvent(this.mainCategory);
}

class UpdatePricingPropertyEvent extends MainCategoryUnitDataEvent {
  final CategoryPropertyEntity pricingProperty;
  UpdatePricingPropertyEvent(this.pricingProperty);
}

class UpdateInventoryPropertyEvent extends MainCategoryUnitDataEvent {
  final CategoryPropertyEntity inventoryProperty;
  UpdateInventoryPropertyEvent(this.inventoryProperty);
}

class SaveMainCategoryUnitDataEvent extends MainCategoryUnitDataEvent {
  final String categoryName;
  SaveMainCategoryUnitDataEvent(this.categoryName);
}
