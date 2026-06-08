import 'package:get_it/get_it.dart';
import 'data/datasources/app_local_data_source.dart';
import 'data/datasources/app_local_data_source_impl.dart';
import 'data/repositories/app_repository_impl.dart';
import 'domain/repositories/app_repository.dart';
import 'domain/usecases/get_app_data.dart';
import 'domain/usecases/save_app_data.dart';
import 'presentation/bloc/app_bloc.dart';

void initAppFeature(GetIt sl) {
  // Bloc
  sl.registerFactory(() => AppBloc(getAppData: sl(), saveAppData: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAppData(sl()));
  sl.registerLazySingleton(() => SaveAppData(sl()));

  // Repository
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AppLocalDataSource>(
    () => AppLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
