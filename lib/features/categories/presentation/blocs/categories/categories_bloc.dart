import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetAllCategoriesUseCase _getAllCategories;
  final DeleteCategoryUseCase _deleteCategory;
  final GetUnitsUseCase _getUnitsUseCase;

  CategoriesBloc({
    required GetAllCategoriesUseCase getAllCategories,
    required AddCategoryUseCase addCategory,
    required UpdateCategoryUseCase updateCategory,
    required DeleteCategoryUseCase deleteCategory,
    required GetUnitsUseCase getUnitsUseCase,
  }) : _getAllCategories = getAllCategories,
       _deleteCategory = deleteCategory,
       _getUnitsUseCase = getUnitsUseCase,
       super(const CategoriesState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<InjectCategoryEvent>(_onInjectCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: CategoriesStatus.loading, message: null));

    final result = await _getAllCategories();

    late final List<CategoryEntity> entities;
    result.fold((failure) {
      emit(state.copyWith(status: CategoriesStatus.failure, message: failure.message));
      entities = const [];
    }, (right) => entities = right);

    if (result.isLeft()) return;

    final unitsResult = await _getUnitsUseCase();
    unitsResult.fold(
      (failure) => emit(state.copyWith(status: CategoriesStatus.failure, message: failure.message)),
      (unitsList) {
        final unitMap = {for (final unit in unitsList) unit.id: unit};

        final categories = entities.map((model) {
          return model.copyWith(
            categoryUnit: unitMap[model.categoryUnitId],
            pricingUnit: unitMap[model.pricingUnitId],
            inventoryUnit: unitMap[model.inventoryUnitId],
          );
        }).toList();

        categories.sort((a, b) => a.categoryName.compareTo(b.categoryName));
        emit(state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
          message: null,
        ));
      },
    );
  }

  Future<void> _onInjectCategory(
    InjectCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.status != CategoriesStatus.success) return;
    emit(state.injectCategory(event.category));
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.status != CategoriesStatus.success) return;

    final result = await _deleteCategory(id: event.category.id);
    result.fold(
      (failure) => emit(state.copyWith(status: CategoriesStatus.failure, message: failure.message)),
      (success) {
        if (!success) {
          emit(state.copyWith(
            status: CategoriesStatus.failure,
            message: 'حدث خطأ أثناء حذف الصنف',
          ));
          return;
        }

        final current = List<CategoryEntity>.from(state.categories)
          ..removeWhere((c) => c.id == event.category.id);
        emit(state.copyWith(categories: current, message: null));
      },
    );
  }
}
