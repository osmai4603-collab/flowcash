import 'package:flowcash/core/datasources/implementations/value_local_data_source_impl.dart';
import 'package:flowcash/core/datasources/interfaces/value_data_source.dart';
import 'package:flowcash/core/repositories/interfaces/value_repository.dart';
import 'package:flowcash/core/repositories/implementations/value_repository_impl.dart';
import 'package:flowcash/core/usecases/value_repository_usecases.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_value_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_value_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/repositories/warehouse_value_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_repository.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_value_repository.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/set_counter.dart';
import 'package:get_it/get_it.dart';

// Data sources (reuse currencies feature implementations)
import 'package:flowcash/features/currencies/data/datasources/currency_data_source.dart';
import 'package:flowcash/features/currencies/data/datasources/currency_local_data_source_impl.dart';
import 'package:flowcash/features/currencies/data/datasources/exchange_price_data_source.dart';
import 'package:flowcash/features/currencies/data/datasources/exchange_price_local_data_source_impl.dart';

// Repositories
import 'package:flowcash/features/currencies/domain/repositories/currency_repository.dart';
import 'package:flowcash/features/currencies/data/repositories/currency_repository_impl.dart';
import 'package:flowcash/features/currencies/domain/repositories/exchange_price_repository.dart';
import 'package:flowcash/features/currencies/data/repositories/exchange_price_repository_impl.dart';

// Use cases
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
// Blocs
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_values_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
// Usecases from settings (registered earlier)
import 'package:flowcash/features/settings/domain/usecases/counters/get_counter.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/increment_counter.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/company/company_cubit.dart';

/// تهيئة الاعتماديات لميزة system.
void initSystemFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<CurrencyDataSource>(
    () => CurrencyLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExchangePriceDataSource>(
    () => ExchangePriceLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WarehouseValueDataSource>(
    () => WarehouseValueLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ValueDataSource>(
        () => ValueLocalDataSourceImpl(sl()),
  );



  // Repositories
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ExchangePriceRepository>(
    () => ExchangePriceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WarehouseValueRepository>(
    () => WarehouseValueRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ValueRepository>(
    () => ValueRepositoryImpl(sl()),
  );

  // Use cases - currencies
  sl.registerLazySingleton(() => GetCurrenciesUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrencyByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertCurrencyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCurrencyUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCurrencyUseCase(sl()));

  // Use cases - exchange prices
  sl.registerLazySingleton(() => GetExchangePricesUseCase(sl()));
  sl.registerLazySingleton(() => GetExchangePriceByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertExchangePriceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExchangePriceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExchangePriceUseCase(sl()));
  sl.registerLazySingleton(() => GetExPriceUseCase(sl()));

  // Use cases - accounting periods
  sl.registerLazySingleton(() => GetAccountingPeriodsUseCase(sl()));
  sl.registerLazySingleton(() => InsertAccountingPeriodUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAccountingPeriodUseCase(sl()));


  sl.registerLazySingleton(() => InsertValueUseCase(sl()));
  sl.registerLazySingleton(() => UpdateValueUseCase(sl()));
  sl.registerLazySingleton(() => DeleteValueUseCase(sl()));
  sl.registerLazySingleton(() => GetValuesUseCase(sl()));
  // Blocs
  sl.registerFactory(() => CurrenciesBloc(sl()));
  sl.registerFactory(() => ExchangeRatesBloc(sl()));
  sl.registerFactory(() => FinancialPeriodsBloc(sl()));
  sl.registerFactory(() => WarehousesBloc(sl()));
  sl.registerFactory(() => WarehouseValuesBloc(sl()));
  sl.registerFactory<ValueCountersBloc>(
    () => ValueCountersBloc(
      sl<GetCounter>(),
      sl<IncrementCounter>(),
      sl<SetCounter>(),
    ),
  );
  sl.registerFactory(() => DefaultsBloc(sl()));
  sl.registerFactory(() => CompanyBloc());


}
