import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategory_form/catalog_form_state.dart';

abstract class SubcategoryFormEvent extends Equatable {
  const SubcategoryFormEvent();

  @override
  List<Object?> get props => [];
}

class InitSubcategoryFormEvent extends SubcategoryFormEvent {
  final int mainCategoryId;
  final SubcategoryEntity? catalog;
  const InitSubcategoryFormEvent(this.mainCategoryId, {this.catalog});

  @override
  List<Object?> get props => [mainCategoryId, catalog];
}

class SubcategoryNameChangedEvent extends SubcategoryFormEvent {
  final String name;
  const SubcategoryNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class SaveSubcategoryEvent extends SubcategoryFormEvent {
  final SubcategoryEntity catalog;
  final Map<int, List<int>> unitsPerProperty;

  const SaveSubcategoryEvent({
    required this.catalog,
    required this.unitsPerProperty,
  });

  @override
  List<Object?> get props => [catalog, unitsPerProperty];
}

class UpdateSelectedUnitEvent extends SubcategoryFormEvent {
  final SubcategoryProperty property;
  final int index;
  final SubcategoryUnit? unit;
  const UpdateSelectedUnitEvent({
    required this.property,
    required this.index,
    required this.unit,
  });

  @override
  List<Object?> get props => [property, index, unit];
}

class AddUnitToPropertyEvent extends SubcategoryFormEvent {
  final SubcategoryProperty catalogProperty;
  final SubcategoryUnit catalogUnit;
  const AddUnitToPropertyEvent({
    required this.catalogProperty,
    required this.catalogUnit,
  });

  @override
  List<Object?> get props => [catalogProperty, catalogUnit];
}

class AddSelectedSlotEvent extends SubcategoryFormEvent {
  final SubcategoryProperty catalogProperty;
  const AddSelectedSlotEvent(this.catalogProperty);

  @override
  List<Object?> get props => [catalogProperty];
}
