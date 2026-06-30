import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

import '../../../../../core/enums/unit_type_enum.dart';

import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

abstract class MainCategoryFormEvent {}

class InitMainCategoryFormEvent extends MainCategoryFormEvent {
  final int? id;
  final MainCategoryEntity? category;
  InitMainCategoryFormEvent({this.id, this.category});
}

class MainCategoryNameChangedEvent extends MainCategoryFormEvent {
  final String name;
  MainCategoryNameChangedEvent(this.name);
}

class MainCategoryUnitChangedEvent extends MainCategoryFormEvent {
  final UnitEntity unit;
  MainCategoryUnitChangedEvent(this.unit);
}

class MainCategoryTypeChangedEvent extends MainCategoryFormEvent {
  final CategoryDefineType type;
  MainCategoryTypeChangedEvent(this.type);
}

class AddPropertyEvent extends MainCategoryFormEvent {
  final CategoryPropertyEntity property;
  AddPropertyEvent(this.property);
}

class RemovePropertyEvent extends MainCategoryFormEvent {
  final int propertyIndex;
  RemovePropertyEvent(this.propertyIndex);
}

class SaveMainCategoryEvent extends MainCategoryFormEvent {
  final MainCategoryEntity category;
  SaveMainCategoryEvent(this.category);
}
