part of 'warehouse_value_form_bloc.dart';

abstract class WarehouseValueFormEvent extends Equatable {
  const WarehouseValueFormEvent();

  @override
  List<Object?> get props => [];
}

class WarehouseValueFormWarehouseIdChanged extends WarehouseValueFormEvent {
  final int warehouseId;

  const WarehouseValueFormWarehouseIdChanged(this.warehouseId);

  @override
  List<Object?> get props => [warehouseId];
}

class WarehouseValueFormTypeChanged extends WarehouseValueFormEvent {
  final WarehouseValueType valueType;

  const WarehouseValueFormTypeChanged(this.valueType);

  @override
  List<Object?> get props => [valueType];
}

class WarehouseValueFormValueChanged extends WarehouseValueFormEvent {
  final String valueText;

  const WarehouseValueFormValueChanged(this.valueText);

  @override
  List<Object?> get props => [valueText];
}

class WarehouseValueFormSubmitted extends WarehouseValueFormEvent {}
