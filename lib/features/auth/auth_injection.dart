import 'package:get_it/get_it.dart';

// Core data sources
import 'package:flowcash/features/auth/data/datasources/interfaces/program_user_data_source.dart';
import 'package:flowcash/features/auth/data/datasources/implementations/program_user_local_data_source.dart';

// Repositories
import 'package:flowcash/features/auth/data/repositories/program_user_repository_impl.dart';
import 'package:flowcash/features/auth/domain/repositories/program_user_repository.dart';

// Use cases
import 'package:flowcash/features/auth/domain/usecases/program_user_repository_usecases.dart';

// Blocs
import 'package:flowcash/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flowcash/features/auth/presentation/bloc/session/session_bloc.dart';

void initAuthFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ProgramUserDataSource>(
    () => ProgramUserLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProgramUserRepository>(
    () => ProgramUserRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProgramUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetProgramUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertProgramUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProgramUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProgramUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserWhereArgsUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereUserNameAndPasswordUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      getAllUsers: sl(),
      addUser: sl(),
      authenticateUser: sl(),
      updateUser: sl(),
    ),
  );

  sl.registerFactory(
    () => SessionBloc(
      getAllUsers: sl(),
      authenticateUser: sl(),
      userSession: sl(),
    ),
  );
}
