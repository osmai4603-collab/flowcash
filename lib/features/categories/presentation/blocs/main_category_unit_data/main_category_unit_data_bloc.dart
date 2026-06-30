import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_state.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category_property_entity.dart';

class MainCategoryUnitDataBloc
    extends Bloc<MainCategoryUnitDataEvent, MainCategoryUnitDataState> {
  MainCategoryUnitDataBloc() : super(MainCategoryUnitDataInitial()) {
    on<InitMainCategoryUnitDataEvent>(_onInit);
    on<UpdatePricingPropertyEvent>(_onUpdatePricingProperty);
    on<UpdateInventoryPropertyEvent>(_onUpdateInventoryProperty);
    on<SaveMainCategoryUnitDataEvent>(_onSave);
  }

  Future<void> _onInit(
    InitMainCategoryUnitDataEvent event,
    Emitter<MainCategoryUnitDataState> emit,
  ) async {
    emit(MainCategoryUnitDataLoadInProgress());
    final GetCategoryPropertiesByMainCategoryUseCase getProps = sl();

    final result = await getProps(event.mainCategory.id);
    result.fold(
      (failure) => emit(MainCategoryUnitDataFailure(failure.message)),
      (properties) {
        final filtered = properties
            .where((property) => !property.unitType.isText)
            .toList();
        final pricingPropertySelected = filtered.isNotEmpty
            ? filtered.firstWhere(
                (p) => p.isPricingUnit,
                orElse: () => filtered.first,
              )
            : null;
        final inventoryPropertySelected = filtered.isNotEmpty
            ? filtered.firstWhere(
                (p) => p.isInventoryUnit,
                orElse: () => filtered.first,
              )
            : null;

        final MainCategoryEntity mainCategory = event.mainCategory.copyWith(
          properties: properties,
        );

        emit(
          MainCategoryUnitDataLoadSuccess(
            category: mainCategory,
            properties: filtered,
            pricingPropertySelected: pricingPropertySelected,
            inventoryPropertySelected: inventoryPropertySelected,
          ),
        );
      },
    );
  }

  void _onUpdatePricingProperty(
    UpdatePricingPropertyEvent event,
    Emitter<MainCategoryUnitDataState> emit,
  ) {
    final state = this.state;
    if (state is MainCategoryUnitDataLoadSuccess) {
      final properties = List<CategoryPropertyEntity>.from(state.properties);
      final indexOfInventoryProperty = properties.indexWhere((property) => property.id == state.inventoryPropertySelected?.id);
      final indexOfPricingProperty = properties.indexWhere((property) => property.id == event.pricingProperty.id);
      for(var index = 0; index < properties.length; index++) {
        properties[index] = properties[index].copyWith(isPricingUnit: index == indexOfPricingProperty);
      }
      emit(
        MainCategoryUnitDataLoadSuccess(
          category: state.category,
          properties: properties,
          pricingPropertySelected: properties[indexOfPricingProperty],
          inventoryPropertySelected: indexOfInventoryProperty > -1 ? properties[indexOfInventoryProperty] : null,
        ),
      );
    }
  }

  void _onUpdateInventoryProperty(
    UpdateInventoryPropertyEvent event,
    Emitter<MainCategoryUnitDataState> emit,
  ) {

    final state = this.state;
    if (state is MainCategoryUnitDataLoadSuccess) {

      final properties = List<CategoryPropertyEntity>.from(state.properties);
      final indexOfInventoryProperty = properties.indexWhere((property) => property.id == event.inventoryProperty.id);
      final indexOfPricingProperty = properties.indexWhere((property) => property.id == state.pricingPropertySelected?.id);
      for(var index = 0; index < properties.length; index++) {
        properties[index] = properties[index].copyWith(isInventoryUnit: index == indexOfInventoryProperty);
      }
      emit(
        MainCategoryUnitDataLoadSuccess(
          category: state.category,
          properties: properties,
          pricingPropertySelected: indexOfPricingProperty > -1 ? properties[indexOfPricingProperty] : null,
          inventoryPropertySelected: properties[indexOfInventoryProperty],
        ),
      );
    }
  }

  Future<void> _onSave(
    SaveMainCategoryUnitDataEvent event,
    Emitter<MainCategoryUnitDataState> emit,
  ) async {
    final state = this.state;
    if (state is! MainCategoryUnitDataLoadSuccess) return;
    emit(MainCategoryUnitDataSaveInProgress());

    final SaveMainCategoryUseCase saveMain = sl();

    final Map<int, CategoryPropertyEntity> updatedPropsMap = {
      for (var p in state.properties) p.id: p,
    };

    final finalProperties = state.category.properties.map((p) {
      return updatedPropsMap[p.id] ?? p;
    }).toList();

    final updated = MainCategoryEntity(
      id: state.category.id,
      name: event.categoryName,
      type: state.category.type,
      properties: state.properties,
      categoryUnitId: state.category.categoryUnitId,
    );
    final result = await saveMain(updated);
    result.fold(
      (failure) => emit(MainCategoryUnitDataFailure(failure.message)),
      (resultId) => emit(MainCategoryUnitDataSaveSuccess(resultId > 0)),
    );
  }
}
