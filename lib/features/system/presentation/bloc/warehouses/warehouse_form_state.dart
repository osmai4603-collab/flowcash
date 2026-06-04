part of 'warehouse_form_bloc.dart';

class WarehouseFormState extends Equatable {
  final WarehouseEntity warehouse;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final WarehouseEntity? savedEntity;

  const WarehouseFormState({
    required this.warehouse,
    required this.isSubmitting,
    required this.isSuccess,
    this.errorMessage,
    this.savedEntity,
  });

  factory WarehouseFormState.initial(WarehouseEntity? initialValue) {
    return WarehouseFormState(
      warehouse: initialValue ?? WarehouseEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        warehouseName: '',
        location: '',
        warehouseType: WarehouseType.values.first,
      ),
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
      savedEntity: null,
    );
  }

  WarehouseFormState copyWith({
    WarehouseEntity? warehouse,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    WarehouseEntity? savedEntity,
  }) {
    return WarehouseFormState(
      warehouse: warehouse ?? this.warehouse,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      savedEntity: savedEntity ?? this.savedEntity,
    );
  }

  @override
  List<Object?> get props => [warehouse, isSubmitting, isSuccess, errorMessage, savedEntity];
}
