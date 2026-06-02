import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'category_form_event.dart';
import 'category_form_state.dart';

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryFormState> {
  final AddCategoryUseCase _addCategory;
  final UpdateCategoryUseCase _updateCategory;
  final GetUnitsUseCase _getUnitsUseCase;
  final CheckCategoryHasRequestsUseCase _checkHasRequestsUseCase;

  CategoryFormBloc({
    required AddCategoryUseCase addCategory,
    required UpdateCategoryUseCase updateCategory,
    required GetUnitsUseCase getUnitsUseCase,
    required CheckCategoryHasRequestsUseCase checkHasRequestsUseCase,
  }) : _addCategory = addCategory,
       _updateCategory = updateCategory,
       _getUnitsUseCase = getUnitsUseCase,
       _checkHasRequestsUseCase = checkHasRequestsUseCase,
       super(const CategoryFormState()) {
    on<InitCategoryForm>(_onInit);
    on<SaveCategoryEvent>(_onSave);
    on<ChangeCategoryUnitEvent>(_onChangeCategoryUnit);
    on<ChangeCategoryTypeEvent>(_onChangeCategoryType);
    on<ChangeBarcodeEvent>(
      (event, emit) => emit(state.copyWithBarcode(barcode: event.barcode)),
    );
    on<ChangeCategoryNameEvent>(_onChangeCattegoryName);
    on<ChangeCategoryNumberEvent>(
      (event, emit) => emit(
        state.copyWithCategoryNumber(
          categoryNumber: event.categoryNumber ?? '',
        ),
      ),
    );
  }

  FutureOr<void> _onChangeCattegoryName(
    ChangeCategoryNameEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    return emit(state.copyWithCategoryName(categoryName: event.categoryName));
  }

  FutureOr<void> _onChangeCategoryUnit(
    ChangeCategoryUnitEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    return emit(state.copyWithCategoryUnit(unit: event.unit));
  }

  Future<void> _onChangeCategoryType(
    ChangeCategoryTypeEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    emit(state.copyWithCategoryType(categoryType: event.categoryType));
  }

  Future<void> _onInit(
    InitCategoryForm event,
    Emitter<CategoryFormState> emit,
  ) async {
    emit(state.copyWith(status: CategoryFormStatus.initial));
    await Future.delayed(const Duration(seconds: 1));

    final unitsResult = await _getUnitsUseCase();
    await unitsResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: CategoryFormStatus.failure,
            messageError: failure.message,
          ),
        );
      },
      (units) async {
        UnitEntity? selectedUnit;
        if (units.isNotEmpty) {
          selectedUnit = units.firstWhere(
            (unit) => unit.unitType.isPiece,
            orElse: () => units.first,
          );
        }

        bool hasRequests = false;
        if (event.category != null) {
          final checkResult = await _checkHasRequestsUseCase(
            event.category!.id,
          );
          checkResult.fold(
            (failure) => hasRequests = false, // fallback
            (val) => hasRequests = val,
          );

          if (units.isNotEmpty) {
            selectedUnit = units.firstWhere(
              (unit) => unit.id == event.category!.categoryUnitId,
              orElse: () => selectedUnit ?? units.first,
            );
          } else {
            selectedUnit = null;
          }
        }

        emit(
          state.copyWith(
            id: event.category?.id,
            categoryName: event.category?.categoryName ?? '',
            categoryNumber: event.category?.categoryNumber ?? '',
            barcode: event.category?.barcode,
            status: CategoryFormStatus.ready,
            initialCategory: event.category,
            units: units,
            selectedUnit: selectedUnit,
            selectedCategoryType:
                event.category?.categoryType ?? CategoryDefineType.commodities,
            hasRequests: hasRequests,
          ),
        );
        debugPrint('\nInit State: $state');
      },
    );
  }

  Future<void> _onSave(
    SaveCategoryEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    emit(state.copyWith(status: CategoryFormStatus.saving));
    await Future.delayed(const Duration(seconds: 1));

    if (state.id == 0) {
      final result = await _addCategory(category: state.toEntity());
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: CategoryFormStatus.failure,
            messageError: failure.message,
          ),
        ),
        (value) {
          final newState = state
              .copyWithStatus(status: CategoryFormStatus.saved)
              .copyWithId(id: value);
          emit(newState);
        },
      );
    } else {
      final result = await _updateCategory(category: state.toEntity());
      result.fold(
        (failure) => emit(
          state
              .copyWithStatus(status: CategoryFormStatus.failure)
              .copyWithError(messageError: failure.message),
        ),
        (value) {
          if (value) {
            emit(state.copyWithStatus(status: CategoryFormStatus.saved));
            return;
          } else {
            emit(
              state
                  .copyWithStatus(status: CategoryFormStatus.failure)
                  .copyWithError(
                    messageError: 'حصل خطأ غير متوقع أثناء تحديث الصنف',
                  ),
            );
          }
        },
      );
    }
  }
}
