import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_category_form_event.dart';
import 'main_category_form_state.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

class MainCategoryFormBloc
    extends Bloc<MainCategoryFormEvent, MainCategoryFormState> {
  final InitMainCategoryFormUseCase initUseCase;
  final SaveMainCategoryUseCase saveUseCase;
  final GetBasicUnits getBasicUnits;

  List<CategoryPropertyEntity> properties = const [];
  List<UnitEntity> units = const [];

  MainCategoryFormBloc({
    required this.initUseCase,
    required this.saveUseCase,
    required this.getBasicUnits,
  }) : super(const MainCategoryFormState()) {
    on<InitMainCategoryFormEvent>(_onInit);
    on<MainCategoryNameChangedEvent>(_onNameChanged);
    on<MainCategoryTypeChangedEvent>(_onTypeChanged);
    on<MainCategoryUnitChangedEvent>(_onUnitChanged);
    on<AddPropertyEvent>(_onAddProperty);
    on<RemovePropertyEvent>(_onRemoveProperty);
    on<SaveMainCategoryEvent>(_onSave);
  }

  Future<void> _onInit(
    InitMainCategoryFormEvent event,
    Emitter<MainCategoryFormState> emit,
  ) async {
    emit(state.copyWith(status: MainCategoryFormStatus.initial));

    final basicUnitsResult = await getBasicUnits();
    units = basicUnitsResult.getOrElse((_) => const <UnitEntity>[]);

    if (event.category != null) {
      final entity = event.category!;
      final selectedUnit = units
          .where((u) => u.id == entity.categoryUnitId)
          .firstOrNull;
      properties = entity.properties;
      emit(
        state.copyWith(
          status: MainCategoryFormStatus.ready,
          id: entity.id,
          name: entity.name,
          type: entity.type,
          categoryUnitId: entity.categoryUnitId,
          selectedUnit: selectedUnit,
        ),
      );
      return;
    }

    if (event.id != null && event.id != 0) {
      final result = await initUseCase(event.id!);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: MainCategoryFormStatus.failure,
            messageError: failure.message,
          ),
        ),
        (entity) {
          if (entity != null) {
            final selectedUnit = units
                .where((u) => u.id == entity.categoryUnitId)
                .firstOrNull;
            properties = entity.properties;
            emit(
              state.copyWith(
                status: MainCategoryFormStatus.ready,
                id: entity.id,
                name: entity.name,
                type: entity.type,
                categoryUnitId: entity.categoryUnitId,
                selectedUnit: selectedUnit,
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: MainCategoryFormStatus.failure,
                messageError: 'الصنف الرئيسي غير موجود',
              ),
            );
          }
        },
      );
    } else {
      final selectedUnit = units.isNotEmpty ? units.first : null;
      emit(
        state.copyWith(
          status: MainCategoryFormStatus.ready,
          selectedUnit: selectedUnit,
        ),
      );
    }
  }

  void _onNameChanged(
    MainCategoryNameChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(name: event.name));
  }

  void _onTypeChanged(
    MainCategoryTypeChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(type: event.type));
  }

  void _onUnitChanged(
    MainCategoryUnitChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(
      state.copyWith(selectedUnit: event.unit, categoryUnitId: event.unit.id),
    );
  }

  void _onAddProperty(
    AddPropertyEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    properties = List<CategoryPropertyEntity>.from(properties)
      ..add(event.property);
  }

  void _onRemoveProperty(
    RemovePropertyEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    if (event.propertyIndex < 0 || event.propertyIndex >= properties.length) {
      return;
    }
    properties = List<CategoryPropertyEntity>.from(properties)
      ..removeAt(event.propertyIndex);
  }

  Future<void> _onSave(
    SaveMainCategoryEvent event,
    Emitter<MainCategoryFormState> emit,
  ) async {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(status: MainCategoryFormStatus.saving));
    await Future.delayed(const Duration(seconds: 1));
    final current = event.category;
    if (current.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: MainCategoryFormStatus.failure,
          messageError: 'يجب إدخال اسم الصنف الرئيسي',
        ),
      );
      emit(state.copyWith(status: MainCategoryFormStatus.ready));
      return;
    }

    final result = await saveUseCase(current);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: MainCategoryFormStatus.failure,
            messageError: failure.message,
          ),
        );
        emit(state.copyWith(status: MainCategoryFormStatus.ready));
      },
      (id) =>
          emit(state.copyWith(status: MainCategoryFormStatus.saved, id: id)),
    );
  }
}
