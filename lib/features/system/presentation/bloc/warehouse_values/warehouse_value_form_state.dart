part of 'warehouse_value_form_bloc.dart';

class WarehouseValueFormState extends Equatable {
  final WarehouseValueEntity? initialValue;
  final bool isEditing;
  final int warehouseId;
  final WarehouseValueType valueType;
  final String valueText;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final WarehouseValueEntity? savedEntity;

  const WarehouseValueFormState({
    required this.initialValue,
    required this.isEditing,
    required this.warehouseId,
    required this.valueType,
    required this.valueText,
    required this.isSubmitting,
    required this.isSuccess,
    required this.errorMessage,
    required this.savedEntity,
  });

  factory WarehouseValueFormState.initial(WarehouseValueEntity? initialValue) {
    return WarehouseValueFormState(
      initialValue: initialValue,
      isEditing: initialValue != null,
      warehouseId: initialValue?.warehouseId ?? 0,
      valueType: initialValue?.valueType ?? WarehouseValueType.values.first,
      valueText: initialValue?.value?.toString() ?? '',
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
      savedEntity: null,
    );
  }

  WarehouseValueFormState copyWith({
    WarehouseValueEntity? initialValue,
    bool? isEditing,
    int? warehouseId,
    WarehouseValueType? valueType,
    String? valueText,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    WarehouseValueEntity? savedEntity,
  }) {
    return WarehouseValueFormState(
      initialValue: initialValue ?? this.initialValue,
      isEditing: isEditing ?? this.isEditing,
      warehouseId: warehouseId ?? this.warehouseId,
      valueType: valueType ?? this.valueType,
      valueText: valueText ?? this.valueText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      savedEntity: savedEntity,
    );
  }

  @override
  List<Object?> get props => [
        initialValue,
        isEditing,
        warehouseId,
        valueType,
        valueText,
        isSubmitting,
        isSuccess,
        errorMessage,
        savedEntity,
      ];
}
