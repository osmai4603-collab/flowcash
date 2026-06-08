import 'package:flutter_bloc/flutter_bloc.dart';
import 'unit_form_event.dart';
import 'unit_form_state.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

class UnitFormBloc extends Bloc<UnitFormEvent, UnitFormState> {
  final GetMainCategoryByIdUseCase _getMainCategory;
  final GetUnitsForPropertyUseCase _getUnits;
  final SaveUnitSelectionUseCase _saveUnit;

  UnitFormBloc({
    required GetMainCategoryByIdUseCase getMainCategory,
    required GetUnitsForPropertyUseCase getUnits,
    required SaveUnitSelectionUseCase saveUnit,
  }) : _getMainCategory = getMainCategory,
       _getUnits = getUnits,
       _saveUnit = saveUnit,
       super(const UnitFormState()) {
    on<InitUnitFormEvent>(_onInit);
    on<SaveUnitFormEvent>(_onSave);
  }

  Future<void> _onInit(
    InitUnitFormEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    emit(state.copyWith(status: UnitFormStatus.loading));
    await Future.delayed(const Duration(seconds: 1));

    final categoryResult = await _getMainCategory(
      event.property.mainCategoryId,
    );
    final unitsResult = await _getUnits(event.property.id);

    final categoryOption = categoryResult.fold(
      (failure) => null,
      (category) => category,
    );

    if (categoryOption == null) {
      final errorMsg = categoryResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(
        state.copyWith(status: UnitFormStatus.failure, messageError: errorMsg),
      );
      return;
    }

    final unitsOption = unitsResult.fold(
      (failure) => <UnitEntity>[],
      (units) => units,
    );

    List<String> measuresUnits = const [];
    String measureUnitSelected = '';
    double initialWeight = 0.0;
    double initialLength = 0.0;
    double initialWidth = 0.0;
    double initialThickness = 1.0;
    String initialName = '';

    final unitType = event.property.unitType;

    if (unitType is WeightUnitType) {
      measuresUnits = const ['كيلو', 'جرام', 'مل'];
      measureUnitSelected =
          event.unit != null && event.unit!.unitName.isNotEmpty
          ? (measuresUnits.firstWhere(
              (u) => u == event.unit!.unitName,
              orElse: () => measuresUnits.first,
            ))
          : measuresUnits.first;
      initialWeight = event.unit?.countUnits ?? 0.0;
    } else if (unitType is LinearMeterUnitType) {
      measuresUnits = const ['متر', 'سم', 'مل'];
      measureUnitSelected =
          event.unit != null && event.unit!.unitName.isNotEmpty
          ? (measuresUnits.firstWhere(
              (u) => u == event.unit!.unitName,
              orElse: () => measuresUnits.first,
            ))
          : measuresUnits.first;
      initialLength = event.unit?.countUnits ?? 0.0;
    } else if (unitType is SquareMeterUnitType ||
        unitType is SquareMeterStaticUnitType ||
        unitType is SquareMeterWidthStaticUnitType ||
        unitType is CubitMeterUnitType) {
      initialLength = event.unit?.length ?? 0.0;
      initialWidth = event.unit?.width ?? 0.0;
      initialThickness = event.unit?.thickness ?? 1.0;
    } else if (unitType is ModelUnitType) {
      initialName = event.unit?.unitName ?? '';
    }

    emit(
      state.copyWith(
        status: UnitFormStatus.ready,
        property: event.property,
        existingUnit: event.unit,
        category: categoryOption,
        units: unitsOption,
        measuresUnits: measuresUnits,
        measureUnitSelected: measureUnitSelected,
        initialWeight: initialWeight,
        initialLength: initialLength,
        initialWidth: initialWidth,
        initialThickness: initialThickness,
        initialName: initialName,
      ),
    );
  }

  Future<void> _onSave(
    SaveUnitFormEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    emit(state.copyWith(status: UnitFormStatus.saving));
    await Future.delayed(const Duration(seconds: 1));
    final result = await _saveUnit(event.unit);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: UnitFormStatus.failure,
          messageError: failure.message,
        ),
      ),
      (unit) async {
        emit(state.copyWith(status: UnitFormStatus.saved, saved: unit));
      },
    );
  }
}
