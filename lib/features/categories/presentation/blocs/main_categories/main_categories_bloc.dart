import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_categories_event.dart';
import 'main_categories_state.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

class MainCategoriesBloc
    extends Bloc<MainCategoriesEvent, MainCategoriesState> {
  final GetAllMainCategoriesUseCase getAllUseCase;
  final AddMainCategoryUseCase addUseCase;
  final DeleteMainCategoryUseCase deleteUseCase;
  final GetBasicUnits getBasicUnits;

  MainCategoriesBloc({
    required this.getAllUseCase,
    required this.addUseCase,
    required this.deleteUseCase,
    required this.getBasicUnits,
  }) : super(MainCategoriesInitial()) {
    on<LoadMainCategoriesEvent>(_onLoad);
    on<RefreshMainCategoriesEvent>(_onLoad);
    on<AddMainCategoryEvent>(_onAdd);
    on<DeleteMainCategoryEvent>(_onDelete);
  }

  Future<void> _onLoad(
    MainCategoriesEvent event,
    Emitter<MainCategoriesState> emit,
  ) async {
    emit(MainCategoriesLoadInProgress());
    final result = await getAllUseCase();
    result.fold(
      (failure) => emit(MainCategoriesOperationFailure(failure.message)),
      (list) async {
        final unitsResult = await getBasicUnits();
        final unitMap = <int, UnitEntity>{};
        unitsResult.fold(
          (_) {},
          (units) {
            for (final unit in units) {
              unitMap[unit.id] = unit;
            }
          },
        );

        final enrichedList = list.map((category) {
          return category.copyWith(
            categoryUnit: unitMap[category.categoryUnitId],
          );
        }).toList();

        emit(MainCategoriesLoadSuccess(enrichedList));
      },
    );
  }

  Future<void> _onAdd(
    AddMainCategoryEvent event,
    Emitter<MainCategoriesState> emit,
  ) async {
    final addResult = await addUseCase(event.category);
    await addResult.fold(
      (failure) async => emit(MainCategoriesOperationFailure(failure.message)),
      (resultEntity) async {
        final listResult = await getAllUseCase();
        listResult.fold(
          (failure) => emit(MainCategoriesOperationFailure(failure.message)),
          (list) => emit(MainCategoriesLoadSuccess(list)),
        );
      },
    );
  }

  Future<void> _onDelete(
    DeleteMainCategoryEvent event,
    Emitter<MainCategoriesState> emit,
  ) async {
    final deleteResult = await deleteUseCase(event.id);
    await deleteResult.fold(
      (failure) async => emit(MainCategoriesOperationFailure(failure.message)),
      (success) async {
        final listResult = await getAllUseCase();
        listResult.fold(
          (failure) => emit(MainCategoriesOperationFailure(failure.message)),
          (list) => emit(MainCategoriesLoadSuccess(list)),
        );
      },
    );
  }
}
