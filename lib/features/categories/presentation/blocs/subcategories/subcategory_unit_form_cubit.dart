import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SubcategoryUnitFormStatus { initial, loading, success, failure }

class SubcategoryUnitFormState extends Equatable {
  final SubcategoryUnitFormStatus status;
  final List<UnitEntity> units;
  final UnitEntity? selectedUnit;
  final String? errorMessage;

  const SubcategoryUnitFormState({
    this.status = SubcategoryUnitFormStatus.initial,
    this.units = const [],
    this.selectedUnit,
    this.errorMessage,
  });

  SubcategoryUnitFormState copyWith({
    SubcategoryUnitFormStatus? status,
    List<UnitEntity>? units,
    UnitEntity? selectedUnit,
    String? errorMessage,
  }) {
    return SubcategoryUnitFormState(
      status: status ?? this.status,
      units: units ?? this.units,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, units, selectedUnit, errorMessage];
}

class SubcategoryUnitFormCubit extends Cubit<SubcategoryUnitFormState> {
  final GetUnitsForPropertyUseCase getUnitsForPropertyUseCase;

  SubcategoryUnitFormCubit({
    required this.getUnitsForPropertyUseCase,
  }) : super(const SubcategoryUnitFormState());

  Future<void> loadUnits(int propertyId) async {
    emit(state.copyWith(status: SubcategoryUnitFormStatus.loading));
    final result = await getUnitsForPropertyUseCase(propertyId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubcategoryUnitFormStatus.failure,
        errorMessage: failure.message,
      )),
      (units) => emit(state.copyWith(
        status: SubcategoryUnitFormStatus.success,
        units: units,
      )),
    );
  }

  void selectUnit(UnitEntity? unit) {
    emit(state.copyWith(selectedUnit: unit));
  }

  void addAndSelectUnit(UnitEntity unit) {
    final updatedUnits = List<UnitEntity>.from(state.units);
    if (!updatedUnits.any((u) => u.id == unit.id)) {
      updatedUnits.add(unit);
    }
    emit(state.copyWith(
      units: updatedUnits,
      selectedUnit: unit,
    ));
  }
}
