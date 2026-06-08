import 'package:get_it/get_it.dart';

// Repositories & Data Sources
import 'package:flowcash/features/accounts/domain/repositories/main_account_repository.dart';
import 'package:flowcash/features/accounts/data/repositories/main_account_repository_impl.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';
import 'package:flowcash/features/accounts/data/repositories/sub_account_repository_impl.dart';

// Use Cases
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
// Blocs
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/trial_balance/trial_balance_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/group_balances/group_balances_bloc.dart';

void initAccountsFeature(GetIt sl) {
  //============================================================
  // Blocs
  //============================================================
  sl.registerFactory(
    () => ChartOfAccountsBloc(
      getMainAccounts: sl(),
      getSubAccounts: sl(),
      deleteMainAccount: sl(),
      deleteSubAccount: sl(),
    ),
  );
  sl.registerFactory(
    () => MainAccountFormBloc(
      insertMainAccount: sl(),
      updateMainAccount: sl(),
      getMaxAccountNumber: sl(),
      getCurrencies: sl(),
    ),
  );
  sl.registerFactory(
    () => SubAccountFormBloc(
      insertSubAccount: sl(),
      updateSubAccount: sl(),
      getMainAccountById: sl(),
      updateCounter: sl(),
      getCurrencies: sl(),
    ),
  );
  sl.registerFactory(
    () => JournalEntriesBloc(
      getJournalEntries: sl(),
      deleteJournalEntry: sl(),
      getJournalItemsByEntryId: sl(),
    ),
  );
  sl.registerFactory(
    () => JournalEntryFormBloc(
      insertJournalEntryWithItems: sl(),
      getJournalItemsByEntryId: sl(),
      updateSubaccountBalance: sl(),
      updateMainAccountBalance: sl(),
      getSubAccounts: sl(),
      getSubAccountById: sl(),
      getMainAccountById: sl(),
      getCurrencies: sl(),
      getExPrice: sl(),
    ),
  );
  sl.registerFactory(
    () => AccountStatementBloc(
      getSubAccountById: sl(),
      getJournalItemsByAccountId: sl(),
      getJournalEntries: sl(),
    ),
  );
  sl.registerFactory(
    () => TrialBalanceBloc(
      getMainAccounts: sl(),
      getSubAccounts: sl(),
      getJournalItems: sl(),
      getJournalEntries: sl(),
    ),
  );
  sl.registerFactory(
    () => GroupBalancesBloc(
      getMainAccounts: sl(),
      getSubAccounts: sl(),
      getJournalItems: sl(),
      getJournalEntries: sl(),
    ),
  );

  //============================================================
  // Repositories
  //============================================================
  sl.registerLazySingleton<MainAccountRepository>(
    () => MainAccountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SubAccountRepository>(
    () => SubAccountRepositoryImpl(sl()),
  );

  //============================================================
  // Main Account Use Cases
  //============================================================
  sl.registerLazySingleton(() => GetMainAccountsUseCase(sl()));
  sl.registerLazySingleton(() => GetMainAccountByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertMainAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMainAccountUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMainAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetMaxAccountNumberUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCounterUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMainAccountBalancesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMainAccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereSubAccountIdUseCase(sl()));
  sl.registerLazySingleton(() => ResetMainAccountBalanceUseCase(sl()));

  //============================================================
  // Sub Account Use Cases
  //============================================================
  sl.registerLazySingleton(() => GetSubAccountsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubAccountByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertSubAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubAccountUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSubAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetSubaccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => GetSubaccountCountHistoriesUseCase(sl()));
  sl.registerLazySingleton(
    () => GetSubaccountCountCreditorHistoriesUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetSubaccountCountDebtorHistoriesUseCase(sl()),
  );
  sl.registerLazySingleton(() => GetSubaccountDebtorBalanceUseCase(sl()));
  sl.registerLazySingleton(() => GetSubaccountCreditorBalanceUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereMainAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetGoodsCostUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubaccountBalancesUseCase(sl()));
  sl.registerLazySingleton(() => ChangeDefaultSubaccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubaccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereMainAccountAndPersonUseCase(sl()));
  sl.registerLazySingleton(() => GetSubaccountsByMainAccountUsecase(sl()));
  sl.registerLazySingleton(() => ResetSubAccountBalancesUseCase(sl()));
}
