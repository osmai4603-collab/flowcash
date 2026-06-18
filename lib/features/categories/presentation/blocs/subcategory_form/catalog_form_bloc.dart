import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
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
  final GetSubcategoryUnitsByMainCategoryUseCase _getSubcategoryUnitsUseCase;
  final InsertSubcategoryUseCase _insertSubcategoryWithUnitsUseCase;
  final UpdateSubcategoryUseCase _updateSubcategoryUseCase;

  SubcategoryFormBloc({
    required GetAllMainCategoriesUseCase getAllMainCategoriesUseCase,
    required GetCategoryPropertiesByMainCategoryUseCase getPropertiesUseCase,
    required GetUnitsByUnitTypes getUnitsUseCase,
    required GetSubcategoryUnitsByMainCategoryUseCase
    getSubcategoryUnitsUseCase,
    required GetSubcategoriesByMainCategoryUseCase getSubcategoriesUseCase,
    required InsertSubcategoryUseCase insertSubcategoryUseCase,
    required UpdateSubcategoryUseCase updateSubcategoryUseCase,
  }) : _getAllMainCategoriesUseCase = getAllMainCategoriesUseCase,
       _getPropertiesUseCase = getPropertiesUseCase,
       _getUnitsByUnitType = getUnitsUseCase,
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
        selectedMainCategory = mainCategories
            .firstWhere((category) => category.id == selectedId);
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

    final unitsResult = await _getUnitsByUnitType(
      properties.map((property) => property.unitType),
    );
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
      return SubcategoryProperty(
        property: property,
        subcatgoriesUnits: catalogUnits,
        selectedUnits: selectedUnits.isEmpty ? [] : selectedUnits,
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

  Future<void> _onSave(
    SaveSubcategoryEvent event,
    Emitter<SubcategoryFormState> emit,
  ) async {
    emit(state.copyWith(status: SubcategoryFormStatus.saving));
    await Future.delayed(const Duration(seconds: 1));
    final result = state.catalogId == 0
        ? await _insertSubcategoryWithUnitsUseCase(state.toEntity())
        : await _updateSubcategoryUseCase(state.toEntity());

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
    print('table');
    final s = state;
    if (s.status != SubcategoryFormStatus.ready) return;
    final selectedUnits = List.of(event.property.selectedUnits);
    if (event.unit == null) {
      if (event.index >= 0 && event.index < selectedUnits.length) {
        selectedUnits.removeAt(event.index);
      }
    } else if (event.index >= 0 && event.index < selectedUnits.length) {
      selectedUnits[event.index] = event.unit!;
    } else {
      selectedUnits.add(event.unit!);
    }
    final property = event.property.copyWith(
      selectedUnits: selectedUnits,
    );
    final properties = List.of(state.catalogProperties);
    final idx = properties.indexWhere(
      (catalogProperty) => catalogProperty.propertyId == property.propertyId,
    );
    if (idx > -1) {
      emit(state.copyWith(catalogProperties: properties..[idx] = property));
    }
  }

  void _onAddUnitToProperty(
    AddUnitToPropertyEvent event,
    Emitter<SubcategoryFormState> emit,
  ) {
    final indexOfProperty = state.catalogProperties.indexWhere(
      (property) => property.propertyId == event.catalogProperty.propertyId,
    );

    var catalogProperty = state.catalogProperties[indexOfProperty];
    catalogProperty = catalogProperty.copyWith(
      catalogUnits: [...List.of(catalogProperty.subcatgoriesUnits), event.catalogUnit],
      selectedUnits:[...List.of(catalogProperty.selectedUnits), event.catalogUnit],
    );
    emit(
      state.copyWith(
        catalogProperties: state.catalogProperties..[indexOfProperty] = catalogProperty,
      ),
    );
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
