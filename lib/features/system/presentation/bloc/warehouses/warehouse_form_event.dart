part of 'warehouse_form_bloc.dart';

abstract class WarehouseFormEvent extends Equatable {
  const WarehouseFormEvent();

  @override
  List<Object?> get props => [];
}

class WarehouseFormNameChanged extends WarehouseFormEvent {
  final String name;

  const WarehouseFormNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class WarehouseFormLocationChanged extends WarehouseFormEvent {
  final String location;

  const WarehouseFormLocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

class WarehouseFormTypeChanged extends WarehouseFormEvent {
  final WarehouseType warehouseType;

  const WarehouseFormTypeChanged(this.warehouseType);

  @override
  List<Object?> get props => [warehouseType];
}

class WarehouseFormParentIdChanged extends WarehouseFormEvent {
  final int? parentId;

  const WarehouseFormParentIdChanged(this.parentId);

  @override
  List<Object?> get props => [parentId];
}

class WarehouseFormSubmitted extends WarehouseFormEvent {
  const WarehouseFormSubmitted();
}
