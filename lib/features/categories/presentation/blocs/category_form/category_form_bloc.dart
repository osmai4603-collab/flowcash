import 'dart:async';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'category_form_event.dart';
import 'category_form_state.dart';

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryFormState> {
  final AddCategoryUseCase _addCategory;
  final UpdateCategoryUseCase _updateCategory;
  final GetBasicUnits _getBasicUnits;
  final GetAllSubcategoriesUseCase _getSubcategories;
  final CheckCategoryHasRequestsUseCase _checkHasRequestsUseCase;
  final GetNewCategoryNumberUseCase _getNewCategoryNumberUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase _getPropertiesUseCase;
  final GetUnitsUseCase _getUnitsUseCase;

  /// البيانات المرجعية - محفوظة في الـ BLoC وليس في الحالة
  List<UnitEntity> _units = [];
  List<SubcategoryEntity> _subcategories = [];
  List<UnitEntity> _inventoriesUnits = [];
  List<UnitEntity> _pricingsUnits = [];

  /// Getters للوصول من الـ UI
  List<UnitEntity> get units => _units;
  List<SubcategoryEntity> get subcategories => _subcategories;
  List<UnitEntity> get inventoriesUnits => _inventoriesUnits;
  List<UnitEntity> get pricingsUnits => _pricingsUnits;

  CategoryFormBloc({
    required AddCategoryUseCase addCategory,
    required UpdateCategoryUseCase updateCategory,
    required GetBasicUnits getUnitsUseCase,
    required GetAllSubcategoriesUseCase getSubcategories,
    required CheckCategoryHasRequestsUseCase checkHasRequestsUseCase,
    required GetNewCategoryNumberUseCase getNewCategoryNumberUseCase,
    required GetCategoryPropertiesByMainCategoryUseCase getPropertiesUseCase,
    required GetUnitsUseCase getUnits,
  }) : _addCategory = addCategory,
       _updateCategory = updateCategory,
       _getBasicUnits = getUnitsUseCase,
       _getSubcategories = getSubcategories,
       _checkHasRequestsUseCase = checkHasRequestsUseCase,
       _getNewCategoryNumberUseCase = getNewCategoryNumberUseCase,
       _getPropertiesUseCase = getPropertiesUseCase,
       _getUnitsUseCase = getUnits,
       super(const CategoryFormState()) {
    on<InitCategoryForm>(_onInit);
    on<SaveCategoryEvent>(_onSave);
    on<ChangeCategoryUnitEvent>(_onChangeCategoryUnit);
    on<ChangeCategorySubcategoryEvent>(_onChangeCategorySubcategory);
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
    on<GenerateCategoryNumberEvent>(_onGenerateCategoryNumber);
    on<ChangeCategoryPricingUnitEvent>(
      (event, emit) => emit(state.copyWith(selectedPricingUnit: event.unit)),
    );
    on<ChangeCategoryInventoryUnitEvent>(
      (event, emit) => emit(state.copyWith(selectedInventoryUnit: event.unit)),
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
    final updatedState = state.copyWithCategoryUnit(unit: event.unit);
    if (state.selectedSubcategory == null) {
      _inventoriesUnits = [event.unit];
      _pricingsUnits = [event.unit];
      return emit(
        updatedState.copyWith(
          selectedPricingUnit: event.unit,
          selectedInventoryUnit: event.unit,
        ),
      );
    }
    return emit(updatedState);
  }

  FutureOr<void> _onChangeCategorySubcategory(
    ChangeCategorySubcategoryEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    final subcategory = event.subcategory;
    if (subcategory == null) {
      final unit = state.selectedUnit;
      _inventoriesUnits = unit != null ? [unit] : [];
      _pricingsUnits = unit != null ? [unit] : [];
      return emit(
        state
            .copyWithSubcategory(subcategory: null)
            .copyWith(selectedPricingUnit: unit, selectedInventoryUnit: unit),
      );
    }

    emit(state.copyWith(status: CategoryFormStatus.initial));

    // 1. Get properties for the subcategory's main category
    final propertiesResult = await _getPropertiesUseCase(
      subcategory.mainCategoryId,
    );
    final properties = propertiesResult.getOrElse((_) => []);

    // 2. Get all units from the database
    final unitsResult = await _getUnitsUseCase();
    final allUnits = unitsResult.getOrElse((_) => []);

    // 3. Filter units to find those that match the properties and subcategory
    // For pricing units: properties where isPricingUnit is true
    final pricingProps = properties.where((p) => p.isPricingUnit).toList();
    final pricingPropIds = pricingProps.map((p) => p.id).toSet();

    // For inventory units: properties where isInventoryUnit is true
    final inventoryProps = properties.where((p) => p.isInventoryUnit).toList();
    final inventoryPropIds = inventoryProps.map((p) => p.id).toSet();

    final List<UnitEntity> filteredPricingUnits = [];
    final List<UnitEntity> filteredInventoryUnits = [];

    for (final subcatUnit in subcategory.units) {
      if (pricingPropIds.contains(subcatUnit.propertyId)) {
        final unit = allUnits
            .where((u) => u.id == subcatUnit.unitId)
            .firstOrNull;
        if (unit != null) {
          filteredPricingUnits.add(unit);
        }
      }
      if (inventoryPropIds.contains(subcatUnit.propertyId)) {
        final unit = allUnits
            .where((u) => u.id == subcatUnit.unitId)
            .firstOrNull;
        if (unit != null) {
          filteredInventoryUnits.add(unit);
        }
      }
    }

    _pricingsUnits = filteredPricingUnits;
    _inventoriesUnits = filteredInventoryUnits;

    UnitEntity? newPricingUnit =
        filteredPricingUnits.firstOrNull ?? state.selectedUnit;
    UnitEntity? newInventoryUnit =
        filteredInventoryUnits.firstOrNull ?? state.selectedUnit;

    emit(
      state
          .copyWithSubcategory(subcategory: subcategory)
          .copyWith(
            status: CategoryFormStatus.ready,
            selectedPricingUnit: newPricingUnit,
            selectedInventoryUnit: newInventoryUnit,
          ),
    );
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

    final unitsResult = await _getBasicUnits();
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
        _units = units;

        UnitEntity? selectedUnit;
        if (units.isNotEmpty) {
          selectedUnit = units.firstWhere(
            (unit) => event.category == null
                ? unit.unitType.isPiece
                : unit.id == event.category!.categoryUnitId,
            orElse: () => units.first,
          );
        }

        final subcategoriesResult = await _getSubcategories();
        SubcategoryEntity? selectedSubcategory;

        subcategoriesResult.fold((failure) => null, (list) {
          _subcategories = list;
          if (event.category?.subcategoryId != null) {
            selectedSubcategory = list
                .where((s) => s.id == event.category!.subcategoryId)
                .firstOrNull;
          }
        });

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

        UnitEntity? selectedPricingUnit;
        UnitEntity? selectedInventoryUnit;
        if (units.isNotEmpty) {
          selectedPricingUnit = units.firstWhere(
            (unit) => event.category != null
                ? unit.id == event.category!.pricingUnitId
                : unit.unitType.isPiece,
            orElse: () => selectedUnit ?? units.first,
          );
          selectedInventoryUnit = units.firstWhere(
            (unit) => event.category != null
                ? unit.id == event.category!.inventoryUnitId
                : unit.unitType.isPiece,
            orElse: () => selectedUnit ?? units.first,
          );
        }

        var categoryNumber = event.category?.categoryNumber ?? '';
        if (categoryNumber.isEmpty) {
          final counterResult = await _getNewCategoryNumberUseCase();
          counterResult.fold(
            (failure) => emit(
              state.copyWith(
                status: CategoryFormStatus.failure,
                messageError: failure.message,
              ),
            ),
            (generatedNumber) => categoryNumber = generatedNumber,
          );
          if (counterResult.isLeft()) {
            return;
          }
        }

        emit(
          state.copyWith(
            id: event.category?.id,
            categoryName: event.category?.categoryName ?? '',
            categoryNumber: categoryNumber,
            barcode: event.category?.barcode,
            status: CategoryFormStatus.ready,
            initialCategory: event.category,
            selectedUnit: selectedUnit,
            selectedSubcategory: selectedSubcategory,
            selectedPricingUnit: selectedPricingUnit,
            selectedInventoryUnit: selectedInventoryUnit,
            selectedCategoryType:
                event.category?.categoryType ?? CategoryDefineType.commodities,
            hasRequests: hasRequests,
          ),
        );
        debugPrint('\nInit State: $state');
      },
    );
  }

  Future<void> _onGenerateCategoryNumber(
    GenerateCategoryNumberEvent event,
    Emitter<CategoryFormState> emit,
  ) async {
    final result = await _getNewCategoryNumberUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CategoryFormStatus.failure,
          messageError: failure.message,
        ),
      ),
      (generatedNumber) =>
          emit(state.copyWithCategoryNumber(categoryNumber: generatedNumber)),
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
        (entity) {
          final newState = state
              .copyWithStatus(status: CategoryFormStatus.saved)
              .copyWithId(id: entity.id);
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
