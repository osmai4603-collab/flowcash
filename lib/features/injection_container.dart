import 'package:flowcash/core/repositories/implementations/accounting_period_repository_impl.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/features/auth/auth_injection.dart';
import 'package:flowcash/features/accounts/accounts_injection.dart';
import 'package:flowcash/features/categories/categories_injection.dart';
import 'package:flowcash/features/transactions/transactions_injection.dart';
import 'package:flowcash/features/settings/settings_injection.dart';
import 'package:flowcash/features/inventory/inventory_injection.dart';
import 'package:flowcash/features/system/system_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flowcash/user_session.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/warehouse_repository_impl.dart';
import 'package:flowcash/core/repositories/interfaces/accounting_period_repository.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_local_data_source_impl.dart';
import 'package:flowcash/core/datasources/interfaces/accounting_period_data_source.dart';
import 'package:flowcash/core/datasources/implementations/accounting_period_local_data_source_impl.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/main_account_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/implementations/main_account_local_data_source_impl.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/implementations/sub_account_local_data_source_impl.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/implementations/journal_entry_local_data_source_impl.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_entry_repository.dart';
import 'package:flowcash/features/accounts/data/repositories/journal_entry_repository_impl.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_item_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/implementations/journal_item_local_data_source_impl.dart';
import 'package:flowcash/features/accounts/domain/repositories/journal_item_repository.dart';
import 'package:flowcash/features/accounts/data/repositories/journal_item_repository_impl.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_item_repository_usecases.dart';

import 'app/app_injection.dart';

/// نقطة الوصول العامة لـ Service Locator.
final sl = GetIt.instance;

/// تهيئة جميع التبعيات (Dependencies) في التطبيق.
///
/// يتم استدعاء هذه الدالة مرة واحدة عند بدء التطبيق
/// قبل [runApp].
Future<void> initDependencies() async {
  //============================================================
  // Core
  //============================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<SqliteService>(() => SqliteService.instance);
  await SqliteService.instance.database;

  //============================================================
  // Core - Data sources
  //============================================================
  sl.registerLazySingleton<WarehouseDataSource>(
    () => WarehouseLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountingPeriodDataSource>(
    () => AccountingPeriodLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MainAccountDataSource>(
    () => MainAccountLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SubAccountDataSource>(
    () => SubAccountLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<JournalEntryDataSource>(
    () => JournalEntryLocalDataSourceImpl(
      sl(),
      (item) => {
        if (item.id > 0) JournalItemsTable.itemId: item.id,
        JournalItemsTable.entryId: item.entryId,
        JournalItemsTable.accountId: item.accountId,
        JournalItemsTable.debit: item.debit,
        JournalItemsTable.credit: item.credit,
        JournalItemsTable.lineDescription: item.lineDescription,
        JournalItemsTable.currencyId: item.currencyId,
        JournalItemsTable.debitBase: item.debitBase,
        JournalItemsTable.creditBase: item.creditBase,
        JournalItemsTable.warehouseId: item.warehouseId,
      },
    ),
  );
  sl.registerLazySingleton<JournalItemDataSource>(
    () => JournalItemLocalDataSourceImpl(sl()),
  );

  //============================================================
  // Core - Repositories
  //============================================================
  sl.registerLazySingleton<WarehouseRepository>(
    () => WarehouseRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AccountingPeriodRepository>(
    () => AccountingPeriodRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<JournalEntryRepository>(
    () => JournalEntryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<JournalItemRepository>(
    () => JournalItemRepositoryImpl(sl()),
  );

  //============================================================
  // Core - Use cases
  //============================================================
  sl.registerLazySingleton(() => GetWarehouseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountingPeriodWhereIdOpenUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalEntriesUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalEntryByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertJournalEntryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateJournalEntryUseCase(sl()));
  sl.registerLazySingleton(() => SaveJournalEntryWithItemsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteJournalEntryUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalItemByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertJournalItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateJournalItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteJournalItemUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalItemsByEntryIdUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalItemsByAccountIdUseCase(sl()));
  sl.registerLazySingleton(() => GetJournalItemsByWarehouseUseCase(sl()));

  //============================================================
  // User Session
  //============================================================
  sl.registerLazySingleton<UserSession>(() => UserSession(sl(), sl()));

  //============================================================
  // Features - App
  //============================================================
  initAppFeature(sl);

  //============================================================
  // Features - Auth
  //============================================================
  initAuthFeature(sl);

  //============================================================
  // Features - Settings
  //============================================================
  initSettingsFeature(sl);

  //============================================================
  // Features - Categories
  //============================================================
  initCategoriesFeature(sl);

  //============================================================
  // Features - Transactions
  //============================================================
  initTransactionsFeature(sl);

  //============================================================
  // Features - Accounts
  //============================================================
  initAccountsFeature(sl);

  //============================================================
  // Features - Inventory
  //============================================================
  initSystemFeature(sl);
  initInventoryFeature(sl);
}
