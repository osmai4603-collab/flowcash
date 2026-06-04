import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalog_form_event.dart';
import 'catalog_form_state.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';

class SubcategoryFormBloc extends Bloc<SubcategoryFormEvent, SubcategoryFormState> {
  final GetMainCategoryByIdUseCase _getMainCategoryUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase _getPropertiesUseCase;
  final GetUnitsByUnitTypes _getUnitsByUnitType;
  final GetSubcategoryUnitsByMainCategoryUseCase _getSubcategoryUnitsUseCase;
  final InsertSubcategoryUseCase _insertSubcategoryWithUnitsUseCase;
  final UpdateSubcategoryUseCase _updateSubcategoryUseCase;

  SubcategoryFormBloc({
    required GetMainCategoryByIdUseCase getMainCategoryUseCase,
    required GetCategoryPropertiesByMainCategoryUseCase getPropertiesUseCase,
    required GetUnitsByUnitTypes getUnitsUseCase,
    required GetSubcategoryUnitsByMainCategoryUseCase getSubcategoryUnitsUseCase,
    required GetSubcategoriesByMainCategoryUseCase getSubcategoriesUseCase,
    required InsertSubcategoryUseCase insertSubcategoryUseCase,
    required UpdateSubcategoryUseCase updateSubcategoryUseCase,
  }) : _getMainCategoryUseCase = getMainCategoryUseCase,
       _getPropertiesUseCase = getPropertiesUseCase,
       _getUnitsByUnitType = getUnitsUseCase,
       _getSubcategoryUnitsUseCase = getSubcategoryUnitsUseCase,
       _insertSubcategoryWithUnitsUseCase = insertSubcategoryUseCase,
        _updateSubcategoryUseCase = updateSubcategoryUseCase,
       super(const SubcategoryFormState()) {
    on<InitSubcategoryFormEvent>(_onInit);
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
      ),
    );
    await Future.delayed(const Duration(seconds: 1));

    // 1. Fetch MainCategory
    final mainCategoryResult = await _getMainCategoryUseCase(
      event.mainCategoryId,
    );
    final mainCategory = mainCategoryResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
        ),
      );
      return null;
    }, (category) => category);
    if (mainCategory == null) return;

    // 2. Fetch properties matching mainCategoryId
    final propertiesResult = await _getPropertiesUseCase(event.mainCategoryId);
    final properties = propertiesResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
        ),
      );
      return null;
    }, (props) => props);
    if (properties == null) return;

    // 3. Fetch basic units
    final unitsResult = await _getUnitsByUnitType(
      properties.map((property) => property.unitType),
    );
    final units = unitsResult.fold((failure) {
      emit(
        state.copyWith(
          status: SubcategoryFormStatus.failure,
          messageError: failure.message,
        ),
      );
      return null;
    }, (uts) => uts);
    if (units == null) return;

    // 4. Fetch catalogInfo if catalogId > 0
    List<SubcategoryUnitEntity> catalogInfos = [];
    if (state.catalogId > 0) {
      final infoResult = await _getSubcategoryUnitsUseCase([event.catalog!.id]);
      catalogInfos = infoResult.fold((_) => [], (infos) => infos);
    }

    // Initialize empty/selected slots for each property
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
      return SubcategoryProperty(
        property: property,
        subcatgoriesUnits: catalogUnits,
        selectedUnits: catalogUnits.where((unit) => unit.id > 0).toList(),
      );
    }).toList();

    // 5. emit state with copyWith
    emit(
      state.copyWith(
        status: SubcategoryFormStatus.ready,
        mainCategory: mainCategory,
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
      ? await _insertSubcategoryWithUnitsUseCase(
      state.toEntity(),
    )
      : await _updateSubcategoryUseCase(
      state.toEntity(),
    );

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
    final property = event.property.copyWith(
      selectedUnits: event.unit == null
          ? (List.of(event.property.selectedUnits)..removeAt(event.index))
          : (List.of(event.property.selectedUnits)..add(event.unit!)),
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
    var catalogProperty = state.catalogProperties.firstWhere(
      (property) => property.propertyId == event.catalogProperty.propertyId,
    );
    catalogProperty = catalogProperty.copyWith(
      catalogUnits: List.of(catalogProperty.subcatgoriesUnits)
        ..add(event.catalogUnit),
      selectedUnits:
          catalogProperty.isSingle
                ? [event.catalogUnit]
                : List.of(catalogProperty.selectedUnits)
            ..add(event.catalogUnit),
    );

    final catalogProperties = List.of(state.catalogProperties);
    final idx = catalogProperties.indexWhere(
      (catalogProperty2) =>
          catalogProperty2.propertyId == catalogProperty.propertyId,
    );

    if (idx > -1) {
      emit(
        state.copyWith(
          catalogProperties: catalogProperties..[idx] = catalogProperty,
        ),
      );
    }
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

