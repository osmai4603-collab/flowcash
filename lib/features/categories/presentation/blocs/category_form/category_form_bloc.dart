import 'dart:async';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import 'category_form_event.dart';
import 'category_form_state.dart';

class CategoryFormBloc extends Bloc<CategoryFormEvent, CategoryFormState> {
  final AddCategoryUseCase _addCategory;
  final UpdateCategoryUseCase _updateCategory;
  final GetBasicUnits _getBasicUnits;
  final GetAllSubcategoriesUseCase _getSubcategories;
  final CheckCategoryHasRequestsUseCase _checkHasRequestsUseCase;
  final GetNewCategoryNumberUseCase _getNewCategoryNumberUseCase;
  final GetUnitsBySubcategoryIdsUseCase _getUnitsBySubcategoryIdsUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase _getCategoryProperties;

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
    required GetUnitsBySubcategoryIdsUseCase getUnitsBySubcategoryIdsUseCase,
    required GetCategoryPropertiesByMainCategoryUseCase getCategoryProperties,
  }) : _addCategory = addCategory,
       _updateCategory = updateCategory,
       _getBasicUnits = getUnitsUseCase,
       _getSubcategories = getSubcategories,
       _checkHasRequestsUseCase = checkHasRequestsUseCase,
       _getNewCategoryNumberUseCase = getNewCategoryNumberUseCase,
       _getUnitsBySubcategoryIdsUseCase = getUnitsBySubcategoryIdsUseCase,
       _getCategoryProperties = getCategoryProperties,
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
      (event, emit) => emit(state.copyWith(selectedPricingUnit: event.unit, selectedInventoryUnit: state.selectedSubcategory == null ? event.unit : null)),
    );
    on<ChangeCategoryInventoryUnitEvent>(
      (event, emit) => emit(state.copyWith(selectedInventoryUnit: event.unit, selectedPricingUnit: state.selectedSubcategory == null ? event.unit : null)),
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
    final updatedState = state.copyWith(
      selectedUnit: event.unit,
      selectedPricingUnit: state.selectedSubcategory == null ? event.unit : null,
      selectedInventoryUnit: state.selectedSubcategory == null ? event.unit : null,
    );
    if (state.selectedSubcategory == null) {
      _inventoriesUnits = [event.unit];
      _pricingsUnits = [event.unit];
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

    final results = await Future.wait([
      _getUnitsBySubcategoryIdsUseCase([subcategory.id]),
      _getCategoryProperties(subcategory.mainCategoryId),
    ]);

    final unitsResult = results[0] as Either<Failure, List<UnitEntity>>;
    final propertiesResult =
        results[1] as Either<Failure, List<CategoryPropertyEntity>>;

    unitsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: CategoryFormStatus.failure,
          messageError: failure.message,
        ),
      ),
      (units) {
        final properties = propertiesResult.getOrElse((_) => []);
        final pricingProperty = properties
            .cast<CategoryPropertyEntity?>()
            .firstWhere(
              (property) => property?.isPricingUnit ?? false,
              orElse: () => null,
            );
        final inventoryProperty = properties
            .cast<CategoryPropertyEntity?>()
            .firstWhere(
              (property) => property?.isInventoryUnit ?? false,
              orElse: () => null,
            );

        _pricingsUnits = units
            .where((unit) => unit.unitType == pricingProperty?.unitType)
            .toList();
        _inventoriesUnits = units
            .where((unit) => unit.unitType == inventoryProperty?.unitType)
            .toList();

        UnitEntity? newPricingUnit =
            _pricingsUnits.firstOrNull ?? state.selectedUnit;
        UnitEntity? newInventoryUnit =
            _inventoriesUnits.firstOrNull ?? state.selectedUnit;

        _pricingsUnits.sort((a, b) => a.measurement.countUnits.compareTo(b.countUnits));
        _inventoriesUnits.sort((a, b) => a.measurement.countUnits.compareTo(b.countUnits));

        emit(
          state.copyWith(
                status: CategoryFormStatus.ready,
                selectedPricingUnit: newPricingUnit,
                selectedInventoryUnit: newInventoryUnit,
            selectedSubcategory: subcategory
              ),
        );
      },
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
          _subcategories.sort((a, b) => a.catalogName.compareTo(b.catalogName));
          if (event.category?.subcategoryId != null) {
            selectedSubcategory = list
                .where((s) => s.id == event.category!.subcategoryId)
                .firstOrNull;
          }
        });

        if (selectedSubcategory != null) {
          final results = await Future.wait([
            _getUnitsBySubcategoryIdsUseCase([selectedSubcategory!.id]),
            _getCategoryProperties(selectedSubcategory!.mainCategoryId),
          ]);

          final subUnitsResult =
              results[0] as Either<Failure, List<UnitEntity>>;
          final propertiesResult =
              results[1] as Either<Failure, List<CategoryPropertyEntity>>;

          subUnitsResult.fold(
            (l) => null,
            (r) {
              final properties = propertiesResult.getOrElse((_) => []);
              final pricingProperty = properties
                  .cast<CategoryPropertyEntity?>()
                  .firstWhere(
                    (property) => property?.isPricingUnit ?? false,
                    orElse: () => null,
                  );
              final inventoryProperty = properties
                  .cast<CategoryPropertyEntity?>()
                  .firstWhere(
                    (property) => property?.isInventoryUnit ?? false,
                    orElse: () => null,
                  );

              _pricingsUnits = r
                  .where((u) => u.unitType == pricingProperty?.unitType)
                  .toList();
              _inventoriesUnits = r
                  .where((u) => u.unitType == inventoryProperty?.unitType)
                  .toList();
            },
          );
        } else {
          _pricingsUnits = selectedUnit == null ? _units : [selectedUnit];
          _inventoriesUnits = selectedUnit == null ? _units : [selectedUnit];
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

        UnitEntity? selectedPricingUnit;
        UnitEntity? selectedInventoryUnit;

        final pricingCandidates = [..._pricingsUnits, ...units];
        final inventoryCandidates = [..._inventoriesUnits, ...units];

        if (pricingCandidates.isNotEmpty) {
          selectedPricingUnit = pricingCandidates.firstWhere(
            (unit) => event.category != null
                ? unit.id == event.category!.pricingUnitId
                : unit.unitType.isPiece,
            orElse: () => selectedUnit ?? pricingCandidates.first,
          );
        }

        if (inventoryCandidates.isNotEmpty) {
          selectedInventoryUnit = inventoryCandidates.firstWhere(
            (unit) => event.category != null
                ? unit.id == event.category!.inventoryUnitId
                : unit.unitType.isPiece,
            orElse: () => selectedUnit ?? inventoryCandidates.first,
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


        _pricingsUnits.sort((a, b) => a.measurement.countUnits.compareTo(b.countUnits));
        _inventoriesUnits.sort((a, b) => a.measurement.countUnits.compareTo(b.countUnits));

        if(_pricingsUnits.isEmpty) _pricingsUnits = _units;
        if(_inventoriesUnits.isEmpty) _inventoriesUnits = _units;

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
