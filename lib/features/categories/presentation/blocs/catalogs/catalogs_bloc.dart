import 'package:flowcash/features/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/generate_categories.dart';
import 'catalogs_event.dart';
import 'catalogs_state.dart';

class SubcategoriesBloc extends Bloc<SubcategoriesEvent, SubcategoriesState> {
  final GetSubcategoriesByMainCategoryUseCase getSubcategoriesByMainCategoryUseCase;
  final GetSubcategoryUnitsByMainCategoryUseCase
  getSubcategoryUnitsByMainCategoryUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase
  getCategoryPropertiesByMainCategoryUseCase;
  final InsertSubcategoryUseCase addSubcategoryUseCase;
  final DeleteSubcategoryUseCase deleteSubcategoryUseCase;

  SubcategoriesBloc({
    required this.getSubcategoriesByMainCategoryUseCase,
    required this.getSubcategoryUnitsByMainCategoryUseCase,
    required this.getCategoryPropertiesByMainCategoryUseCase,
    required this.addSubcategoryUseCase,
    required this.deleteSubcategoryUseCase,
  }) : super(const SubcategoriesState()) {
    on<LoadSubcategoriesEvent>(_onLoadSubcategories);
    on<RefreshSubcategoriesEvent>(_onRefreshSubcategories);
    on<SearchSubcategoriesEvent>(_onSearchSubcategories);
    on<AddSubcategoryEvent>(_onAddSubcategory);
    on<DeleteSubcategoryEvent>(_onDeleteSubcategory);
    on<GenerateSubcategoryCategoriesEvent>(_onGenerateCategories);
    on<AddSubcategoryUnitEvent>(_onAddSubcategoryUnit);
    on<DeleteSubcategoryUnitEvent>(_onDeleteSubcategoryUnit);
  }

  Future<void> _onLoadSubcategories(
    LoadSubcategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SubcategoriesStatus.loading,
        errorMessage: null,
        statusMessage: null,
      ),
    );
    final catalogsResult = await getSubcategoriesByMainCategoryUseCase(
      event.mainCategoryId,
    );
    await catalogsResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: SubcategoriesStatus.error,
          errorMessage: failure.message,
          statusMessage: null,
        ),
      ),
      (catalogs) async {
        final infosResult = await getSubcategoryUnitsByMainCategoryUseCase(
          catalogs.map((catalog) => catalog.id).toList(),
        );
        await infosResult.fold(
          (failure) async => emit(
            state.copyWith(
              status: SubcategoriesStatus.error,
              errorMessage: failure.message,
              statusMessage: null,
            ),
          ),
          (infos) async {
            final propertiesResult =
                await getCategoryPropertiesByMainCategoryUseCase(
                  event.mainCategoryId,
                );
            propertiesResult.fold(
              (failure) => emit(
                state.copyWith(
                  status: SubcategoriesStatus.error,
                  errorMessage: failure.message,
                  statusMessage: null,
                ),
              ),
              (properties) => emit(
                state.copyWith(
                  status: SubcategoriesStatus.loaded,
                  catalogs: catalogs,
                  infos: infos,
                  properties: properties,
                  statusMessage: null,
                ),
              ),
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
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onAddSubcategory(
    AddSubcategoryEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    emit(state.copyWith(
      catalogs: List.from(state.catalogs)..add(event.catalog),
      statusMessage: 'Subcategory added successfully',
    ));
  }

  Future<void> _onDeleteSubcategory(
    DeleteSubcategoryEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    final result = await deleteSubcategoryUseCase(event.catalogId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubcategoriesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (success) {
        if (success) {
          final updatedSubcategories = state.catalogs
              .where((catalog) => catalog.id != event.catalogId)
              .toList();
          final updatedInfos = state.infos
              .where((info) => info.subcategoryId != event.catalogId)
              .toList();
          emit(state.copyWith(catalogs: updatedSubcategories, infos: updatedInfos));
        } else {
          emit(
            state.copyWith(
              status: SubcategoriesStatus.error,
              errorMessage: 'Failed to delete catalog',
            ),
          );
        }
      },
    );
  }

  Future<void> _onGenerateCategories(
    GenerateSubcategoryCategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
     await GenerateCategories(
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
  }

  Future<void> _onAddSubcategoryUnit(
    AddSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    // final result = await addSubcategoryUnitUseCase(event.catalogId, event.unitId, event.propertyId);
    // result.fold(
    //   (failure) => emit(
    //     state.copyWith(
    //       status: SubcategoriesStatus.error,
    //       errorMessage: failure.message,
    //     ),
    //   ),
    //   (info) {
    //     final updatedInfos = List<SubcategoryUnitEntity>.from(state.infos)
    //       ..add(info);
    //     emit(state.copyWith(infos: updatedInfos));
    //   },
    // );
  }

  Future<void> _onDeleteSubcategoryUnit(
    DeleteSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    // final result = await deleteSubcategoryUnitUseCase(event.infoId);
    // result.fold(
    //   (failure) => emit(
    //     state.copyWith(
    //       status: SubcategoriesStatus.error,
    //       errorMessage: failure.message,
    //     ),
    //   ),
    //   (success) {
    //     if (success) {
    //       final updatedInfos = state.infos
    //           .where((info) => info.id != event.infoId)
    //           .toList();
    //       emit(state.copyWith(infos: updatedInfos));
    //     } else {
    //       emit(
    //         state.copyWith(
    //           status: SubcategoriesStatus.error,
    //           errorMessage: 'Failed to delete catalog info',
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}
