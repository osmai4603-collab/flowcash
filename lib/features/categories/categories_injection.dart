import 'package:get_it/get_it.dart';

// Data Sources
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/main_category_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/subcategory_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/subcategory_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/unit_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/category_property_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_property_local_data_source_impl.dart';
import 'package:flowcash/features/categories/data/datasources/category_attribute_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/category_attribute_local_data_source_impl.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';

// Repositories
import 'package:flowcash/features/categories/domain/repositories/category_repository.dart';
import 'package:flowcash/features/categories/data/repositories/category_repository_impl.dart';
import 'package:flowcash/features/categories/domain/repositories/main_category_repository.dart';
import 'package:flowcash/features/categories/data/repositories/main_category_repository_impl.dart';
import 'package:flowcash/features/categories/domain/repositories/subcategory_repository.dart';
import 'package:flowcash/features/categories/data/repositories/subcategory_repository_impl.dart';
import 'package:flowcash/features/categories/domain/repositories/unit_repository.dart';
import 'package:flowcash/features/categories/data/repositories/unit_repository_impl.dart';
import 'package:flowcash/features/categories/domain/repositories/category_property_repository.dart';
import 'package:flowcash/features/categories/data/repositories/category_property_repository_impl.dart';
import 'package:flowcash/features/categories/domain/repositories/category_attribute_repository.dart';
import 'package:flowcash/features/categories/data/repositories/category_attribute_repository_impl.dart';

// Use Cases
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_attribute_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_property_usecases.dart';

// Blocs
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategory_form/catalog_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategory_unit_form_cubit.dart';

void initCategoriesFeature(GetIt sl) {
  //============================================================
  // Features - Categories
  //============================================================

  // Data Sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(
      sl()
    ),
  );
  sl.registerLazySingleton<MainCategoryLocalDataSource>(
    () => MainCategoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SubcategoryLocalDataSource>(
    () => SubcategoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UnitLocalDataSource>(
    () => UnitLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CategoryAttributeDataSource>(
    () => CategoryAttributeLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoryPropertyDataSource>(
    () => CategoryPropertyLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MainCategoryRepository>(
    () => MainCategoryRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<SubcategoryRepository>(
    () => SubcategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UnitRepository>(() => UnitRepositoryImpl(sl()));
  sl.registerLazySingleton<CategoryPropertyRepository>(
    () => CategoryPropertyRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CategoryAttributeRepository>(
    () => CategoryAttributeRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryByIdUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryAttributeUseCase(sl()));
  sl.registerLazySingleton(() => HasCategoryNameUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesWhereContainsNameUseCase(sl()));
  sl.registerLazySingleton(() => GetNewCategoryNumberUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerLazySingleton(() => CheckCategoryHasRequestsUseCase());

  // Main categories use cases
  sl.registerLazySingleton(() => GetAllMainCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddMainCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMainCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetMainCategoryByIdUseCase(sl()));
  sl.registerLazySingleton(() => InitMainCategoryFormUseCase(sl()));
  sl.registerLazySingleton(() => SaveMainCategoryUseCase(sl()));

  // Subcategories use cases
  sl.registerLazySingleton(() => GetSubcategoriesByMainCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAllSubcategoriesUseCase(sl()));
  sl.registerLazySingleton(
    () => GetSubcategoryUnitsByMainCategoryUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetSubcategoryUnitsBySubcategoryIdsUseCase(sl()),
  );
  sl.registerLazySingleton(() => GetSubcategoryByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertSubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubcategoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteSubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => SaveSubcategoryWithUnitsUseCase(sl()));
  sl.registerLazySingleton(() => AddSubcategoryUnitUseCase(sl()));
  sl.registerLazySingleton(() => GenerateSubcategoryCategoriesUseCase(sl()));

  // Property use cases
  sl.registerLazySingleton(
    () => GetCategoryPropertiesByMainCategoryUseCase(sl()),
  );

  // Unit use cases
  sl.registerLazySingleton(() => GetUnitsByUnitTypes(sl()));
  sl.registerLazySingleton(() => GetUnitsByMainCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitsForPropertyUseCase(sl()));
  sl.registerLazySingleton(
    () => GetAvailableUnitsForSubcategoryPropertyUseCase(sl()),
  );
  sl.registerLazySingleton(() => SaveUnitSelectionUseCase(sl()));
  sl.registerLazySingleton(() => GetBasicUnits(sl()));

  // Blocs
  sl.registerFactory(
    () => CategoriesBloc(
      getAllCategories: sl(),
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      getUnitsUseCase: sl(),
      getAllSubcategoriesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => MainCategoriesBloc(
      getAllUseCase: sl(),
      addUseCase: sl(),
      deleteUseCase: sl(),
      getBasicUnits: sl(),
    ),
  );
  sl.registerFactory(
    () => MainCategoryFormBloc(initUseCase: sl(), saveUseCase: sl(), getBasicUnits: sl()),
  );
  sl.registerFactory(
    () => SubcategoriesBloc(
      getSubcategoriesByMainCategoryUseCase: sl(),
      getAllSubcategoriesUseCase: sl(),
      getSubcategoryUnitsByMainCategoryUseCase: sl(),
      getCategoryPropertiesByMainCategoryUseCase: sl(),
      addSubcategoryUseCase: sl(),
      deleteSubcategoryUseCase: sl(),
      getAllMainCategoriesUseCase: sl(),
      addSubcategoryUnitUseCase: sl(),
      generateSubcategoryCategoriesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SubcategoryFormBloc(
      getAllMainCategoriesUseCase: sl(),
      getPropertiesUseCase: sl(),
      getUnitsUseCase: sl(),
      getUnitsByMainCategoryUseCase: sl(),
      getBasicUnitsUseCase: sl(),
      getSubcategoryUnitsUseCase: sl(),
      getSubcategoriesUseCase: sl(),
      insertSubcategoryUseCase: sl(),
      updateSubcategoryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SubcategoryUnitFormCubit(
      getAvailableUnitsForSubcategoryPropertyUseCase: sl(),
    ),
  );
}
