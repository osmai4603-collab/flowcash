import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

abstract class UnitFormEvent {}

class InitUnitFormEvent extends UnitFormEvent {
  final CategoryPropertyEntity property;
  final UnitEntity? unit;
  InitUnitFormEvent(this.property, this.unit);
}

class SaveUnitFormEvent extends UnitFormEvent {
  final UnitEntity unit;
  SaveUnitFormEvent(this.unit);
}

