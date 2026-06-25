import 'package:flowcash/core/datasources/interfaces/person_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_accounting_use_case.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_bloc.dart';
import 'package:get_it/get_it.dart';

// Data sources
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_data_source.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_order_data_source.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_transaction_data_source.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_bond_data_source.dart';
import 'package:flowcash/features/transactions/data/datasources/implementations/bill_local_data_source_impl.dart';
import 'package:flowcash/features/transactions/data/datasources/implementations/bill_order_local_data_source_impl.dart';
import 'package:flowcash/features/transactions/data/datasources/implementations/financial_transaction_local_data_source_impl.dart';
import 'package:flowcash/features/transactions/data/datasources/implementations/financial_bond_local_data_source_impl.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';

// Repositories
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:flowcash/features/transactions/data/repositories/bill_repository_impl.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_order_repository.dart';
import 'package:flowcash/features/transactions/data/repositories/bill_order_repository_impl.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_transaction_repository.dart';
import 'package:flowcash/features/transactions/data/repositories/financial_transaction_repository_impl.dart';
import 'package:flowcash/features/transactions/domain/repositories/financial_bond_repository.dart';
import 'package:flowcash/features/transactions/data/repositories/financial_bond_repository_impl.dart';

// Use cases
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_order_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/financial_transaction_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/financial_bond_repository_usecases.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_bloc.dart';

void initTransactionsFeature(GetIt sl) {
  //============================================================
  // Features - Transactions
  //============================================================

  // Data sources
  sl.registerLazySingleton<BillDataSource>(
    () => BillLocalDataSourceImpl(
      sl(),
      (order) => {
        if (order.id > 0) BillOrdersTable.id: order.id,
        BillOrdersTable.billId: order.billId,
        BillOrdersTable.categoryId: order.categoryId,
        BillOrdersTable.countUnits: order.countUnits,
        BillOrdersTable.totalPrice: order.totalPrice,
      },
    ),
  );
  sl.registerLazySingleton<BillOrderDataSource>(
    () => BillOrderLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FinancialTransactionDataSource>(
    () => FinancialTransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FinancialBondDataSource>(
    () => FinancialBondLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton<BillOrderRepository>(
    () => BillOrderRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FinancialTransactionRepository>(
    () => FinancialTransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FinancialBondRepository>(
    () => FinancialBondRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBillsUseCase(sl()));
  sl.registerLazySingleton(() => GetBillsWithCustomerUseCase(sl()));
  sl.registerLazySingleton(() => GetBillByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertBillUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBillUseCase(sl()));
  sl.registerLazySingleton(() => PostBillToAccountingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBillUseCase(sl()));
  sl.registerLazySingleton(() => GetBillOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetBillOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertBillOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBillOrderUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBillOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetSumUnitWhereOrderUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereCategoryIdUseCase(sl()));
  sl.registerLazySingleton(() => GetFinancialTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetFinancialTransactionByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertFinancialTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFinancialTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFinancialTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetFinancialBondsUseCase(sl()));
  sl.registerLazySingleton(() => GetFinancialBondByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertFinancialBondUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFinancialBondUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFinancialBondUseCase(sl()));

  // Presentation Blocs
  sl.registerFactory(
    () => BillsBloc(
      getBillsUseCase: sl(),
      insertBillUseCase: sl(),
      updateBillUseCase: sl(),
      deleteBillUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FinancialTransactionsBloc(
      getFinancialTransactionsUseCase: sl(),
      insertFinancialTransactionUseCase: sl(),
      updateFinancialTransactionUseCase: sl(),
      deleteFinancialTransactionUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FinancialBondsBloc(
      getFinancialBondsUseCase: sl(),
      insertFinancialBondUseCase: sl(),
      updateFinancialBondUseCase: sl(),
      deleteFinancialBondUseCase: sl(),
    ),
  );
}
