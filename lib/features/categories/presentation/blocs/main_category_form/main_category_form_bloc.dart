import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_category_form_event.dart';
import 'main_category_form_state.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';

class MainCategoryFormBloc
    extends Bloc<MainCategoryFormEvent, MainCategoryFormState> {
  final InitMainCategoryFormUseCase initUseCase;
  final SaveMainCategoryUseCase saveUseCase;

  MainCategoryFormBloc({required this.initUseCase, required this.saveUseCase})
    : super(const MainCategoryFormState()) {
    on<InitMainCategoryFormEvent>(_onInit);
    on<MainCategoryNameChangedEvent>(_onNameChanged);
    on<UnitNameChangedEvent>(_onUnitNameChanged);
    on<MainCategoryTypeChangedEvent>(_onTypeChanged);
    on<AddPropertyEvent>(_onAddProperty);
    on<RemovePropertyEvent>(_onRemoveProperty);
    on<SaveMainCategoryEvent>(_onSave);
  }

  Future<void> _onInit(
    InitMainCategoryFormEvent event,
    Emitter<MainCategoryFormState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (event.id != null) {
      final result = await initUseCase(event.id);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: MainCategoryFormStatus.failure,
            messageError: failure.message,
          ),
        ),
        (entity) {
          if (entity != null) {
            emit(
              state.copyWith(
                status: MainCategoryFormStatus.ready,
                id: entity.id,
                name: entity.name,
                type: entity.type,
                unitName: entity.unitName,
                properties: entity.properties,
                unitType: entity.unitType,
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
      emit(state.copyWith(status: MainCategoryFormStatus.ready));
    }
  }

  void _onNameChanged(
    MainCategoryNameChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(name: event.name));
  }

  void _onUnitNameChanged(
    UnitNameChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(unitName: event.unitName));
  }

  void _onTypeChanged(
    MainCategoryTypeChangedEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    emit(state.copyWith(type: event.type));
  }

  void _onAddProperty(
    AddPropertyEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    final properties = List<CategoryPropertyEntity>.from(state.properties)
      ..add(event.property);
    emit(state.copyWith(properties: properties));
  }

  void _onRemoveProperty(
    RemovePropertyEvent event,
    Emitter<MainCategoryFormState> emit,
  ) {
    if (state.status != MainCategoryFormStatus.ready) return;
    if (event.propertyIndex < 0 ||
        event.propertyIndex >= state.properties.length) {
      return;
    }
    final properties = List<CategoryPropertyEntity>.from(state.properties)
      ..removeAt(event.propertyIndex);
    emit(state.copyWith(properties: properties));
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
      return;
    }

    final result = await saveUseCase(current);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MainCategoryFormStatus.failure,
          messageError: failure.message,
        ),
      ),
      (id) =>
          emit(state.copyWith(status: MainCategoryFormStatus.saved, id: id)),
    );
  }
}
