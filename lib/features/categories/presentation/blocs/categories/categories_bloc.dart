import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetAllCategoriesUseCase _getAllCategories;
  final DeleteCategoryUseCase _deleteCategory;
  final GetUnitsUseCase _getUnitsUseCase;
  final GetAllSubcategoriesUseCase _getAllSubcategoriesUseCase;
  CategoriesController _categories = CategoriesController([]);

  CategoriesBloc({
    required GetAllCategoriesUseCase getAllCategories,
    required AddCategoryUseCase addCategory,
    required UpdateCategoryUseCase updateCategory,
    required DeleteCategoryUseCase deleteCategory,
    required GetUnitsUseCase getUnitsUseCase,
    required GetAllSubcategoriesUseCase getAllSubcategoriesUseCase,
  }) : _getAllCategories = getAllCategories,
       _deleteCategory = deleteCategory,
       _getUnitsUseCase = getUnitsUseCase,
       _getAllSubcategoriesUseCase = getAllSubcategoriesUseCase,
       super(const CategoriesInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<InjectCategoryEvent>(_onInjectCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoadInProgress());

    final result = await _getAllCategories();

    result.fold((failure) {
      emit(CategoriesLoadFailure(failure.message));
      _categories = CategoriesController([]);
    }, (right) => _categories = CategoriesController(right));

    if (result.isLeft()) return;

    final unitsResult = await _getUnitsUseCase();
    final subcategoriesResult = await _getAllSubcategoriesUseCase();

    unitsResult.fold(
      (failure) => emit(CategoriesLoadFailure(failure.message)),
      (unitsList) {
        subcategoriesResult.fold(
          (failure) => emit(CategoriesLoadFailure(failure.message)),
          (subcategoriesList) {
            final unitMap = {for (final unit in unitsList) unit.id: unit};
            final subcategoryMap = {
              for (final sub in subcategoriesList) sub.id: sub,
            };

            final categories = _categories().map((model) {
              return model.copyWith(
                categoryUnit: unitMap[model.categoryUnitId],
                pricingUnit: unitMap[model.pricingUnitId],
                inventoryUnit: unitMap[model.inventoryUnitId],
                subcategory: subcategoryMap[model.subcategoryId],
              );
            }).toList();

            categories.sort((a, b) => a.categoryName.compareTo(b.categoryName));
            emit(CategoriesLoadSuccess(categories: categories));
          },
        );
      },
    );
  }

  Future<void> _onInjectCategory(
    InjectCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is! CategoriesLoadSuccess) return;
    _categories.replace(event.category);
    emit(CategoriesLoadSuccess(categories: _categories.categories));
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final state = this.state;
    if (state is! CategoriesLoadSuccess) return;

    final result = await _deleteCategory(id: event.category.id);
    result.fold((failure) => emit(CategoriesLoadFailure(failure.message)), (
      success,
    ) {
      if (!success) {
        emit(const CategoriesLoadFailure('حدث خطأ أثناء حذف الصنف'));
        return;
      }
      _categories.remove(event.category);
      emit(CategoriesLoadSuccess(categories: _categories.categories));
    });
  }
}
