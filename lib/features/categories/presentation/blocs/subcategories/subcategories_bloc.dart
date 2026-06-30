import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_event.dart';
import 'subcategories_event.dart';
import 'subcategories_state.dart';

class SubcategoriesBloc extends Bloc<SubcategoriesEvent, SubcategoriesState> {
  final GetSubcategoriesByMainCategoryUseCase
  getSubcategoriesByMainCategoryUseCase;
  final GetAllSubcategoriesUseCase getAllSubcategoriesUseCase;
  final GetSubcategoryUnitsByMainCategoryUseCase
  getSubcategoryUnitsByMainCategoryUseCase;
  final GetCategoryPropertiesByMainCategoryUseCase
  getCategoryPropertiesByMainCategoryUseCase;
  final InsertSubcategoryUseCase addSubcategoryUseCase;
  final DeleteSubcategoryUseCase deleteSubcategoryUseCase;
  final GetAllMainCategoriesUseCase getAllMainCategoriesUseCase;
  final AddSubcategoryUnitUseCase addSubcategoryUnitUseCase;
  final GenerateSubcategoryCategoriesUseCase generateSubcategoryCategoriesUseCase;
  final DeleteSubcategoryUnitUseCase deleteSubcategoryUnitUseCase;

  SubcategoriesController _controller = SubcategoriesController([], [], []);

  SubcategoriesBloc({
    required this.getSubcategoriesByMainCategoryUseCase,
    required this.getAllSubcategoriesUseCase,
    required this.getSubcategoryUnitsByMainCategoryUseCase,
    required this.getCategoryPropertiesByMainCategoryUseCase,
    required this.addSubcategoryUseCase,
    required this.deleteSubcategoryUseCase,
    required this.getAllMainCategoriesUseCase,
    required this.addSubcategoryUnitUseCase,
    required this.generateSubcategoryCategoriesUseCase,
    required this.deleteSubcategoryUnitUseCase,
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

    final mainCatsResult = await getAllMainCategoriesUseCase();
    final mainCategories = mainCatsResult.fold(
      (failure) => <MainCategoryEntity>[],
      (list) => list,
    );

    final catalogsResult = event.mainCategoryId == null
        ? await getAllSubcategoriesUseCase()
        : await getSubcategoriesByMainCategoryUseCase(event.mainCategoryId!);

    await catalogsResult.fold(
      (failure) async => emit(SubcategoriesLoadFailure(failure.message)),
      (catalogs) async {
        final infosResult = await getSubcategoryUnitsByMainCategoryUseCase(
          catalogs.map((catalog) => catalog.id).toList(),
        );

        await infosResult.fold(
          (failure) async => emit(SubcategoriesLoadFailure(failure.message)),
          (infos) async {
            final unitIds = infos.map((info) => info.unitId).toSet();
            final unitsResult = await sl<GetUnitsUseCase>()(ids: unitIds);
            final unitsMap = unitsResult.fold(
              (failure) => <int, UnitEntity>{},
              (units) => {for (var unit in units) unit.id: unit},
            );

            final populatedInfos = infos.map((info) {
              final unit = unitsMap[info.unitId];
              return info.copyWith(unitName: unit?.unitName);
            }).toList();

            final propertiesResult = await _loadPropertiesForSubcategories(
              catalogs,
              emit,
            );

            propertiesResult.fold(
              (failure) => emit(SubcategoriesLoadFailure(failure.message)),
              (properties) {
                _controller = SubcategoriesController(
                  catalogs,
                  populatedInfos,
                  properties,
                );
                emit(
                  SubcategoriesLoadSuccess(
                    controller: _controller,
                    mainCategories: mainCategories,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, List<CategoryPropertyEntity>>>
  _loadPropertiesForSubcategories(
    List<SubcategoryEntity> catalogs,
    Emitter<SubcategoriesState> emit,
  ) async {
    final mainCategoryIds = catalogs
        .map((catalog) => catalog.mainCategoryId)
        .toSet()
        .toList();

    final properties = <CategoryPropertyEntity>[];

    for (final mainCategoryId in mainCategoryIds) {
      final propertiesResult = await getCategoryPropertiesByMainCategoryUseCase(
        mainCategoryId,
      );

      propertiesResult.fold(
        (failure) {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(
            SubcategoriesLoadFailure(
              'Failed to load properties for main category $mainCategoryId: \n  ${failure.message}',
            ),
          );
        },
        (foundProperties) {
          properties.addAll(foundProperties);
        },
      );
    }

    final uniqueProperties = <int, CategoryPropertyEntity>{};
    for (final property in properties) {
      uniqueProperties[property.id] = property;
    }

    return Right(uniqueProperties.values.toList());
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
    emit(
      currentState.copyWith(
        controller: _controller,
        statusMessage: 'Subcategory added successfully',
      ),
    );
  }

  Future<void> _onDeleteSubcategory(
    DeleteSubcategoryEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;

    final result = await deleteSubcategoryUseCase(event.catalogId);
    result.fold((failure) => emit(SubcategoriesLoadFailure(failure.message)), (
      success,
    ) {
      if (!success) {
        emit(const SubcategoriesLoadFailure('Failed to delete catalog'));
        return;
      }
      _controller.removeSubcategory(event.catalogId);
      emit(currentState.copyWith(controller: _controller));
    });
  }

  Future<void> _onGenerateCategories(
    GenerateSubcategoryCategoriesEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final currentState = state as SubcategoriesLoadSuccess;

    emit(currentState.copyWith(isGenerating: true));

    try {
      final result = await generateSubcategoryCategoriesUseCase(event.catalogId);

      result.fold(
        (failure) {
          emit(SubcategoriesLoadFailure(failure.message));
        },
        (categories) {
          try {
            final categoriesBloc = sl<CategoriesBloc>();
            for (var category in categories) {
              categoriesBloc.add(InjectCategoryEvent(category));
            }
          } catch (e) {
            debugPrint('Failed to inject categories to CategoriesBloc: $e');
          }

          final names = categories.map((c) => c.categoryName).toList();
          emit(
            currentState.copyWith(
              isGenerating: false,
              generatedCategoryNames: names,
              statusMessage: null,
            ),
          );
        },
      );
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
    emit(
      currentState.copyWith(generatedCategoryNames: null, statusMessage: null),
    );
  }

  Future<void> _onAddSubcategoryUnit(
    AddSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;

    final unitEntity = SubcategoryUnitEntity(
      id: 0,
      subcategoryId: event.catalogId,
      unitId: event.unitId,
      propertyId: event.propertyId,
    );

    final result = await addSubcategoryUnitUseCase(unitEntity);
    result.fold((failure) => emit(SubcategoriesLoadFailure(failure.message)), (
      info,
    ) {
      add(const LoadSubcategoriesEvent());
    });
  }

  Future<void> _onDeleteSubcategoryUnit(
    DeleteSubcategoryUnitEvent event,
    Emitter<SubcategoriesState> emit,
  ) async {
    if (state is! SubcategoriesLoadSuccess) return;
    final result = await deleteSubcategoryUnitUseCase(event.infoId);
    result.fold(
      (failure) => emit(SubcategoriesLoadFailure(failure.message)),
      (success) {
        if (!success) {
          emit(const SubcategoriesLoadFailure('Failed to delete catalog info'));
          return;
        }
        _controller.removeSubcategoryUnit(event.infoId);
        final currentState = state as SubcategoriesLoadSuccess;
        emit(currentState.copyWith(controller: _controller));
      },
    );
  }
}
