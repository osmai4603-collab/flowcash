import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_state.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

        final MainCategoryEntity mainCategory = event.mainCategory;

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
      emit(
        MainCategoryUnitDataLoadSuccess(
          category: state.category,
          properties: state.properties,
          pricingPropertySelected: event.pricingProperty,
          inventoryPropertySelected: state.inventoryPropertySelected,
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
      emit(
        MainCategoryUnitDataLoadSuccess(
          category: state.category,
          properties: state.properties,
          pricingPropertySelected: state.pricingPropertySelected,
          inventoryPropertySelected: event.inventoryProperty,
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

    // NOTE: detailed property updates and category resets belong to usecases/repository layer.
    // For now update the main category name via `SaveMainCategoryUseCase` when changed.
    final SaveMainCategoryUseCase saveMain = sl();
    final updated = MainCategoryEntity(
      id: state.category.id,
      name: event.categoryName,
      type: state.category.type,
      properties: state.category.properties,
      unitName: state.category.unitName,
      unitType: state.category.unitType,
    );
    final result = await saveMain(updated);
    result.fold(
      (failure) => emit(MainCategoryUnitDataFailure(failure.message)),
      (resultId) => emit(MainCategoryUnitDataSaveSuccess(resultId > 0)),
    );
  }
}
