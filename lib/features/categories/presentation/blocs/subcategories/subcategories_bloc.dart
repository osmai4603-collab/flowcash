import 'package:flowcash/features/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/generate_categories.dart';
import 'subcategories_event.dart';
import 'subcategories_state.dart';

class SubcategoriesBloc extends Bloc<SubcategoriesEvent, SubcategoriesState> {
  final GetSubcategoriesByMainCategoryUseCase getSubcategoriesByMainCategoryUseCase;
  final GetSubcategoryUnitsByMainCategoryUseCase getSubcategoryUnitsByMainCategoryUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase getCategoryPropertiesByMainCategoryUseCase;
  final InsertSubcategoryUseCase addSubcategoryUseCase;
  final DeleteSubcategoryUseCase deleteSubcategoryUseCase;

  SubcategoriesController _controller = SubcategoriesController([], [], []);

  SubcategoriesBloc({
    required this.getSubcategoriesByMainCategoryUseCase,
    required this.getSubcategoryUnitsByMainCategoryUseCase,
    required this.getCategoryPropertiesByMainCategoryUseCase,
    required this.addSubcategoryUseCase,
    required this.deleteSubcategoryUseCase,
  }) : super(const SubcategoriesInitial()) {
    on<LoadSubcategoriesEvent>(_onLoadSubcategories);
    on<RefreshSubcategoriesEvent>(_onRefreshSubcategories);
    on<SearchSubcategoriesEvent>(_onSearchSubcategories);
    on<AddSubcategoryEvent>(_onAddSubcategory);
    on<DeleteSubcategoryEvent>(_onDeleteSubcategory);
    on<GenerateSubcategoryCategoriesEvent>(_onGenerateCategories);
    on<ClearGeneratedCategoriesEvent>(_onClearGeneratedCategories);
    on<AddSubcategoryUnitEvent>(_onAddSubcategoryUnit);
    on<DeleteSubcategoryUnitEvent>(_onDeleteSubcategoryUnit);
  }

  Future<void> _onLoadSubcategories(
    LoadSubcategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    emit(const SubcategoriesLoadInProgress());

    final catalogsResult = await getSubcategoriesByMainCategoryUseCase(
      event.mainCategoryId,
    );

    await catalogsResult.fold(
      (failure) async => emit(SubcategoriesLoadFailure(failure.message)),
      (catalogs) async {
        final infosResult = await getSubcategoryUnitsByMainCategoryUseCase(
          catalogs.map((catalog) => catalog.id).toList(),
        );

        await infosResult.fold(
          (failure) async => emit(SubcategoriesLoadFailure(failure.message)),
          (infos) async {
            final propertiesResult =
                await getCategoryPropertiesByMainCategoryUseCase(
              event.mainCategoryId,
            );

            propertiesResult.fold(
              (failure) => emit(SubcategoriesLoadFailure(failure.message)),
              (properties) {
                _controller = SubcategoriesController(catalogs, infos, properties);
                emit(SubcategoriesLoadSuccess(controller: _controller));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshSubcategories(
    RefreshSubcategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    add(LoadSubcategoriesEvent(event.mainCategoryId));
  }

  void _onSearchSubcategories(
    SearchSubcategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;
    emit(currentState.copyWith(searchQuery: event.query));
  }

  Future<void> _onAddSubcategory(
    AddSubcategoryEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;

    _controller.addSubcategory(event.catalog);
    emit(currentState.copyWith(
      controller: _controller,
      statusMessage: 'Subcategory added successfully',
    ));
  }

  Future<void> _onDeleteSubcategory(
    DeleteSubcategoryEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;

    final result = await deleteSubcategoryUseCase(event.catalogId);
    result.fold(
      (failure) => emit(SubcategoriesLoadFailure(failure.message)),
      (success) {
        if (!success) {
          emit(const SubcategoriesLoadFailure('Failed to delete catalog'));
          return;
        }
        _controller.removeSubcategory(event.catalogId);
        emit(currentState.copyWith(controller: _controller));
      },
    );
  }

  Future<void> _onGenerateCategories(
    GenerateSubcategoryCategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;

    emit(const SubcategoriesLoadInProgress());

    try {
      final categories = await GenerateCategories(
        usecases: CategoriesUsecases(
          getMainCategoryById: sl(),
          getUnits: sl(),
          addCategory: sl(),
          addCategoryAttribute: sl(),
          hasCategoryName: sl(),
          getNewCategoryNumber: sl(),
          getSubcategoryById: sl(),
          getCategoryPropertiesByMainCategory: sl(),
          getSubcategoryUnitsBySubcategoryIds: sl(),
        ),
      ).startGeneratingCategories(event.catalogId);

      final names = categories.map((c) => c.categoryName).toList();
      emit(currentState.copyWith(generatedCategoryNames: names, statusMessage: null));
    } catch (e) {
      emit(SubcategoriesLoadFailure(e.toString()));
    }
  }

  Future<void> _onClearGeneratedCategories(
    ClearGeneratedCategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;
    emit(currentState.copyWith(generatedCategoryNames: null, statusMessage: null));
  }

  Future<void> _onAddSubcategoryUnit(
    AddSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    // final result = await addSubcategoryUnitUseCase(event.catalogId, event.unitId, event.propertyId);
    // result.fold(
    //   (failure) => emit(SubcategoriesLoadFailure(failure.message)),
    //   (info) {
    //     _controller.addSubcategoryUnit(info);
    //     final currentState = state as SubcategoriesLoadSuccess;
    //     emit(currentState.copyWith(controller: _controller));
    //   },
    // );
  }

  Future<void> _onDeleteSubcategoryUnit(
    DeleteSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    // final result = await deleteSubcategoryUnitUseCase(event.infoId);
    // result.fold(
    //   (failure) => emit(SubcategoriesLoadFailure(failure.message)),
    //   (success) {
    //     if (!success) {
    //       emit(const SubcategoriesLoadFailure('Failed to delete catalog info'));
    //       return;
    //     }
    //     _controller.removeSubcategoryUnit(event.infoId);
    //     final currentState = state as SubcategoriesLoadSuccess;
    //     emit(currentState.copyWith(controller: _controller));
    //   },
    // );
  }
}
