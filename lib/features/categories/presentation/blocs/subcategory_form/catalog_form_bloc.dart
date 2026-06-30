import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalog_form_event.dart';
import 'catalog_form_state.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';


class SubcategoryFormBloc
    extends Bloc<SubcategoryFormEvent, SubcategoryFormState> {
  final GetAllMainCategoriesUseCase _getAllMainCategoriesUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase _getPropertiesUseCase;
  final GetUnitsByUnitTypes _getUnitsByUnitType;
  final GetUnitsByMainCategoryUseCase _getUnitsByMainCategoryUseCase;
  final GetBasicUnits _getBasicUnits;
  final GetSubcategoryUnitsByMainCategoryUseCase _getSubcategoryUnitsUseCase;
  final InsertSubcategoryUseCase _insertSubcategoryWithUnitsUseCase;
  final UpdateSubcategoryUseCase _updateSubcategoryUseCase;

  SubcategoryFormBloc({
    required GetAllMainCategoriesUseCase getAllMainCategoriesUseCase,
    required GetCategoryPropertiesByMainCategoryUseCase getPropertiesUseCase,
    required GetUnitsByUnitTypes getUnitsUseCase,
    required GetUnitsByMainCategoryUseCase getUnitsByMainCategoryUseCase,
    required GetBasicUnits getBasicUnitsUseCase,
    required GetSubcategoryUnitsByMainCategoryUseCase
    getSubcategoryUnitsUseCase,
    required GetSubcategoriesByMainCategoryUseCase getSubcategoriesUseCase,
    required InsertSubcategoryUseCase insertSubcategoryUseCase,
    required UpdateSubcategoryUseCase updateSubcategoryUseCase,
  }) : _getAllMainCategoriesUseCase = getAllMainCategoriesUseCase,
       _getPropertiesUseCase = getPropertiesUseCase,
       _getUnitsByUnitType = getUnitsUseCase,
       _getUnitsByMainCategoryUseCase = getUnitsByMainCategoryUseCase,
       _getBasicUnits = getBasicUnitsUseCase,
       _getSubcategoryUnitsUseCase = getSubcategoryUnitsUseCase,
       _insertSubcategoryWithUnitsUseCase = insertSubcategoryUseCase,
       _updateSubcategoryUseCase = updateSubcategoryUseCase,
       super(const SubcategoryFormState()) {
    on<InitSubcategoryFormEvent>(_onInit);
    on<MainCategorySelectedEvent>(_onMainCategorySelected);
    on<SubcategoryNameChangedEvent>(_onNameChanged);
    on<SaveSubcategoryEvent>(_onSave);
    on<UpdateSelectedUnitEvent>(_onUpdateSelectedUnit);
    on<AddUnitToPropertyEvent>(_onAddUnitToProperty);
    on<AddSelectedSlotEvent>(_onAddSelectedSlot);
  }

  Future<void> _onInit(
    InitSubcategoryFormEvent event,
    Emitter<SubcategoryFormState> emit,
  ) async {
    emit(
      state.copyWith(
        catalogId: event.catalog?.id,
        catalogName: event.catalog?.catalogName,
        catalogNumber: event.catalog?.catalogNumber,
        status: SubcategoryFormStatus.initial,
        catalogProperties: const [],
        mainCategory: null,
        mainCategories: const [],
      ),
    );
    await Future.delayed(const Duration(seconds: 1));

    final mainCategoriesResult = await _getAllMainCategoriesUseCase();
    final mainCategories = mainCategoriesResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
        ),
      );
      return const <MainCategoryEntity>[];
    }, (categories) => categories);

    final int? selectedId = event.catalog?.mainCategoryId;
    MainCategoryEntity? selectedMainCategory;
    if (selectedId != null && selectedId > 0) {
      try {
        selectedMainCategory = mainCategories.firstWhere(
          (category) => category.id == selectedId,
        );
      } catch (_) {
        selectedMainCategory = null;
      }
    }

    if (selectedMainCategory == null) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.ready,
          mainCategories: mainCategories,
        ),
      );
      return;
    }

    await _loadPropertiesForMainCategory(
      selectedMainCategory,
      state.catalogId,
      emit,
      mainCategories,
    );
  }

  Future<void> _onMainCategorySelected(
    MainCategorySelectedEvent event,
    Emitter<SubcategoryFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SubcategoryFormStatus.initial,
        mainCategory: event.mainCategory,
        catalogProperties: const [],
      ),
    );

    await _loadPropertiesForMainCategory(
      event.mainCategory,
      state.catalogId,
      emit,
      state.mainCategories,
    );
  }

  Future<void> _loadPropertiesForMainCategory(
    MainCategoryEntity mainCategory,
    int catalogId,
    Emitter<SubcategoryFormState> emit,
    List<MainCategoryEntity> mainCategories,
  ) async {
    final propertiesResult = await _getPropertiesUseCase(mainCategory.id);
    final properties = propertiesResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
          mainCategories: mainCategories,
          mainCategory: mainCategory,
        ),
      );
      return null;
    }, (props) => props);
    if (properties == null) return;

    final unitsResult = await _getUnitsByMainCategoryUseCase(mainCategory.id);
    final units = unitsResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
          mainCategories: mainCategories,
          mainCategory: mainCategory,
        ),
      );
      return null;
    }, (uts) => uts);
    if (units == null) return;

    // تحميل الوحدات الأساسية ودمجها مع وحدات الصنف الرئيسي
    final basicUnitsResult = await _getBasicUnits();
    final basicUnits = basicUnitsResult.getOrElse((_) => const <UnitEntity>[]);
    if (basicUnits.isNotEmpty) {
      final existingIds = units.map((u) => u.id).toSet();
      final newBasicUnits = basicUnits.where(
        (basicUnit) => !existingIds.contains(basicUnit.id),
      );
      units.addAll(newBasicUnits);
    }

    List<SubcategoryUnitEntity> catalogInfos = [];
    if (catalogId > 0) {
      final infoResult = await _getSubcategoryUnitsUseCase([catalogId]);
      catalogInfos = infoResult.fold((_) => [], (infos) => infos);
    }

    final listProperties = properties.map((property) {
      final catalogUnits = units
          .where((unit) => unit.unitType == property.unitType)
          .map((unit) {
            final catalogInfoIndex = catalogInfos.indexWhere(
              (catalogUnit) =>
                  unit.id == catalogUnit.unitId &&
                  catalogUnit.propertyId == property.id,
            );
            return SubcategoryUnit(
              id: catalogInfoIndex > -1 ? catalogInfos[catalogInfoIndex].id : 0,
              property: property,
              unit: unit,
            );
          })
          .toList();
      final selectedUnits = catalogUnits.where((unit) => unit.id > 0).toList();

      // في حالة إدخال بيانات جديدة: إذا كانت الخاصية isSingle ولديها وحدة واحدة فقط، يتم تحديدها تلقائياً
      final autoSelected = (catalogId == 0 &&
              property.isSingle &&
              selectedUnits.isEmpty &&
              catalogUnits.length == 1)
          ? [catalogUnits.first]
          : selectedUnits;

      return SubcategoryProperty(
        property: property,
        subcatgoriesUnits: catalogUnits,
        selectedUnits: autoSelected.isEmpty ? [] : autoSelected,
      );
    }).toList();

    emit(
      state.copyWith(
        status: SubcategoryFormStatus.ready,
        mainCategory: mainCategory,
        mainCategories: mainCategories,
        catalogProperties: listProperties,
      ),
    );
  }

  void _onNameChanged(
    SubcategoryNameChangedEvent event,
    Emitter<SubcategoryFormState> emit,
  ) {
    if (state.status == SubcategoryFormStatus.ready) {
      emit(state.copyWith(catalogName: event.name));
    }
  }

  Future<UnitEntity?> _getBasicUnit(int unitId) async {
    final basicUnitsResult = await _getBasicUnits();
    return basicUnitsResult.fold(
      (_) => null,
      (units) {
        if (units.isEmpty) return null;
        try {
          return units.firstWhere((u) => u.id == unitId);
        } catch (_) {
          return units.first;
        }
      },
    );
  }

  Future<void> _onSave(
    SaveSubcategoryEvent event,
    Emitter<SubcategoryFormState> emit,
  ) async {
    emit(state.copyWith(status: SubcategoryFormStatus.saving));

    final updatedProperties = List<SubcategoryProperty>.from(
      state.catalogProperties,
    );
    bool propertiesUpdated = false;

    for (int i = 0; i < updatedProperties.length; i++) {
      final prop = updatedProperties[i];
      if (!prop.property.isCategoryUnit && prop.selectedUnits.isEmpty) {
        final basicUnit = await _getBasicUnit(state.mainCategory!.categoryUnitId);
        if (basicUnit != null) {
          final catalogUnit = prop.createSubcategoryUnit(unit: basicUnit);
          updatedProperties[i] = prop.copyWith(selectedUnits: [catalogUnit]);
          propertiesUpdated = true;
        }
      } else if (prop.property.isCategoryUnit) {
        // Sync from event if provided
        final selectedIds = event.unitsPerProperty[prop.propertyId];
        if (selectedIds != null) {
          final newSelected = prop.subcatgoriesUnits
              .where((u) => selectedIds.contains(u.unitId))
              .toList();
          updatedProperties[i] = prop.copyWith(selectedUnits: newSelected);
          propertiesUpdated = true;
        }
      }
    }

    final finalState = propertiesUpdated
        ? state.copyWith(catalogProperties: updatedProperties)
        : state;

    await Future.delayed(const Duration(seconds: 1));
    final result = finalState.catalogId == 0
        ? await _insertSubcategoryWithUnitsUseCase(finalState.toEntity())
        : await _updateSubcategoryUseCase(finalState.toEntity());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
        ),
      ),
      (savedCatalog) => emit(
        state.copyWith(
          status: SubcategoryFormStatus.saved,
          savedSubcategory: savedCatalog,
        ),
      ),
    );
  }

  void _onUpdateSelectedUnit(
    UpdateSelectedUnitEvent event,
    Emitter<SubcategoryFormState> emit,
  ) {
    final s = state;
    if (s.status != SubcategoryFormStatus.ready) return;

    final selectedUnits = List<SubcategoryUnit>.from(
      event.property.selectedUnits,
    );
    if (event.unit == null) {
      if (event.index >= 0 && event.index < selectedUnits.length) {
        selectedUnits.removeAt(event.index);
      }
    } else if (event.index >= 0 && event.index < selectedUnits.length) {
      selectedUnits[event.index] = event.unit!;
    } else {
      selectedUnits.add(event.unit!);
    }

    final property = event.property.copyWith(selectedUnits: selectedUnits);

    final properties = List<SubcategoryProperty>.from(state.catalogProperties);
    final idx = properties.indexWhere(
      (catalogProperty) => catalogProperty.propertyId == property.propertyId,
    );

    if (idx > -1) {
      properties[idx] = property;
      emit(state.copyWith(catalogProperties: properties));
    }
  }

  void _onAddUnitToProperty(
    AddUnitToPropertyEvent event,
    Emitter<SubcategoryFormState> emit,
  ) {
    final indexOfProperty = state.catalogProperties.indexWhere(
      (property) => property.propertyId == event.catalogProperty.propertyId,
    );

    if (indexOfProperty == -1) return;

    var catalogProperty = state.catalogProperties[indexOfProperty];

    // التحقق من عدم تكرار الوحدة في مصفوفة الوحدات
    final isDuplicateInUnits = catalogProperty.subcatgoriesUnits.any(
      (existing) => existing.unitId == event.catalogUnit.unitId,
    );
    final isDuplicateInSelected = catalogProperty.selectedUnits.any(
      (existing) => existing.unitId == event.catalogUnit.unitId,
    );

    catalogProperty = catalogProperty.copyWith(
      catalogUnits: isDuplicateInUnits
          ? catalogProperty.subcatgoriesUnits
          : [...catalogProperty.subcatgoriesUnits, event.catalogUnit],
      selectedUnits: isDuplicateInSelected
          ? catalogProperty.selectedUnits
          : [...catalogProperty.selectedUnits, event.catalogUnit],
    );

    final newProperties = List<SubcategoryProperty>.from(
      state.catalogProperties,
    );
    newProperties[indexOfProperty] = catalogProperty;

    emit(state.copyWith(catalogProperties: newProperties));
  }

  void _onAddSelectedSlot(
    AddSelectedSlotEvent event,
    Emitter<SubcategoryFormState> emit,
  ) {
    final s = state;
    if (s.status != SubcategoryFormStatus.ready) return;

    final propertyIndex = s.catalogProperties.indexWhere(
      (catalogProperty) =>
          catalogProperty.propertyId == event.catalogProperty.propertyId,
    );
    if (propertyIndex == -1) return;

    final catalogProperty = s.catalogProperties[propertyIndex];
    final selectedUnitIds = catalogProperty.selectedUnits
        .whereType<SubcategoryUnit>()
        .map((unit) => unit.unit.id)
        .toSet();
    final availableUnits = catalogProperty.subcatgoriesUnits
        .where((unit) => !selectedUnitIds.contains(unit.unit.id))
        .toList();

    if (availableUnits.isEmpty) return;

    final updated = catalogProperty.copyWith(
      selectedUnits: List.of(catalogProperty.selectedUnits)
        ..add(availableUnits.first),
    );

    final newProperties = List.of(s.catalogProperties)
      ..[propertyIndex] = updated;

    emit(s.copyWith(catalogProperties: newProperties));
  }
}
