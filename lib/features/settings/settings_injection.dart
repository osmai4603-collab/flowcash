import 'package:flowcash/core/services/sqlite/sqlite_database_manager.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/set_counter.dart';
import 'package:get_it/get_it.dart';

// Database Repositories & Use Cases
import 'package:flowcash/features/settings/domain/repositories/database_repository.dart';
import 'package:flowcash/features/settings/data/repositories/database_repository_impl.dart';
import 'package:flowcash/features/settings/domain/usecases/database/backup_database.dart';
import 'package:flowcash/features/settings/domain/usecases/database/restore_database.dart';

// Data sources
import 'package:flowcash/features/settings/data/datasources/interfaces/app_value_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/interfaces/value_counter_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/implementations/app_value_local_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/implementations/value_counter_local_data_source.dart';

// Repositories
import 'package:flowcash/features/settings/data/repositories/app_value_repository_impl.dart';
import 'package:flowcash/features/settings/data/repositories/value_counter_repository_impl.dart';
import 'package:flowcash/features/settings/domain/repositories/app_value_repository.dart';
import 'package:flowcash/core/repositories/interfaces/value_counter_repository.dart';

// Use cases
import 'package:flowcash/core/usecases/value_counter_repository_usecases.dart';
import 'package:flowcash/features/settings/domain/usecases/values/get_all_values.dart';
import 'package:flowcash/features/settings/domain/usecases/values/get_value_by_type.dart';
import 'package:flowcash/features/settings/domain/usecases/values/update_value.dart';
import 'package:flowcash/features/settings/domain/usecases/values/get_local_currency.dart';
import 'package:flowcash/features/settings/domain/usecases/values/get_company_info.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/get_counter.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/increment_counter.dart';

// Blocs
import 'package:flowcash/features/settings/presentation/bloc/settings/settings_bloc.dart';

void initSettingsFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AppValueDataSource>(
    () => AppValueLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ValueCounterDataSource>(
    () => ValueCounterLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AppValueRepository>(
    () => AppValueRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ValueCounterRepository>(
    () => ValueCounterRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DatabaseRepository>(
    () => DatabaseRepositoryImpl(SqliteDatabaseManager.instance),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllValues(sl()));
  sl.registerLazySingleton(() => GetValueByType(sl()));
  sl.registerLazySingleton(() => UpdateValue(sl()));
  sl.registerLazySingleton(() => GetLocalCurrency(sl()));
  sl.registerLazySingleton(() => GetCompanyInfo(sl()));
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));
  sl.registerLazySingleton(() => SetCounter(sl()));
  sl.registerLazySingleton(() => BackupDatabaseUseCase(sl()));
  sl.registerLazySingleton(() => RestoreDatabaseUseCase(sl()));

  // Core ValueCounter UseCases
  sl.registerLazySingleton(() => GetValueCountersUseCase(sl()));
  sl.registerLazySingleton(() => GetValueCounterByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetValueCounterByCounterTypeUseCase(sl()));
  sl.registerLazySingleton(() => InsertValueCounterUseCase(sl()));
  sl.registerLazySingleton(() => UpdateValueCounterUseCase(sl()));
  sl.registerLazySingleton(() => DeleteValueCounterUseCase(sl()));
  sl.registerLazySingleton(() => GetNextCounterUseCase(sl()));
  sl.registerLazySingleton(() => GetNextCounterByGroupUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => SettingsBloc(
      getAllValues: sl(),
      updateValue: sl(),
      getCompanyInfo: sl(),
      getCounter: sl(),
      incrementCounter: sl(),
      backupDatabaseUseCase: sl(),
      restoreDatabaseUseCase: sl(),
    ),
  );
}
