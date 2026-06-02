import 'package:get_it/get_it.dart';

// Data sources
import 'package:flowcash/features/settings/data/datasources/interfaces/app_value_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/interfaces/value_counter_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/implementations/app_value_local_data_source.dart';
import 'package:flowcash/features/settings/data/datasources/implementations/value_counter_local_data_source.dart';

// Repositories
import 'package:flowcash/features/settings/data/repositories/app_value_repository_impl.dart';
import 'package:flowcash/features/settings/data/repositories/value_counter_repository_impl.dart';
import 'package:flowcash/features/settings/domain/repositories/app_value_repository.dart';
import 'package:flowcash/features/settings/domain/repositories/value_counter_repository.dart';

// Use cases
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

  // Use cases
  sl.registerLazySingleton(() => GetAllValues(sl()));
  sl.registerLazySingleton(() => GetValueByType(sl()));
  sl.registerLazySingleton(() => UpdateValue(sl()));
  sl.registerLazySingleton(() => GetLocalCurrency(sl()));
  sl.registerLazySingleton(() => GetCompanyInfo(sl()));
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));

  // Blocs
  sl.registerFactory(
    () => SettingsBloc(
      getAllValues: sl(),
      updateValue: sl(),
      getCompanyInfo: sl(),
      getCounter: sl(),
      incrementCounter: sl(),
    ),
  );
}
