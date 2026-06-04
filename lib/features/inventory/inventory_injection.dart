import 'package:get_it/get_it.dart';

// Data Sources
import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_catalog_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_catalog_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_data_source.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_order_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_order_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/opening_quantity_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/opening_quantity_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/goods_cost_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/goods_cost_local_data_source_impl.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_value_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/warehouse_value_local_data_source_impl.dart';

// Repositories
import 'package:flowcash/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_catalog_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/inventory_catalog_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_transaction_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/inventory_transaction_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/inventory_transaction_order_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/inventory_transaction_order_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/opening_quantity_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/opening_quantity_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/goods_cost_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/goods_cost_repository_impl.dart';
import 'package:flowcash/features/inventory/domain/repositories/warehouse_value_repository.dart';
import 'package:flowcash/features/inventory/data/repositories/warehouse_value_repository_impl.dart';

// Use Cases
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_catalog_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_order_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/opening_quantity_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/goods_cost_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_value_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';

// Blocs (to be created)
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/transactions/transactions_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/warehouse_transfers/warehouse_transfers_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_bloc.dart';

void initInventoryFeature(GetIt sl) {
  //============================================================
  // Blocs
  //============================================================
  sl.registerFactory(
    () => InventoryCatalogBloc(
      getInventorys: sl(),
      insertInventory: sl(),
      updateInventory: sl(),
      deleteInventory: sl(),
      getInventorySubcategories: sl(),
      getMainAccounts: sl(),
      getSubAccounts: sl(),
    ),
  );

  // Batches feature removed: no DI registrations

  sl.registerFactory(
    () => TransactionsBloc(
      getTransactions: sl(),
      insertTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      getTransactionOrders: sl(),
      insertOrder: sl(),
      deleteOrder: sl(),
      getWarehouses: sl(),
    ),
  );

  sl.registerFactory(
    () => WarehouseTransfersBloc(
      getTransactions: sl(),
      insertTransaction: sl(),
      deleteTransaction: sl(),
      getTransactionOrders: sl(),
      insertOrder: sl(),
      deleteOrder: sl(),
      getWarehouses: sl(),
    ),
  );

  sl.registerFactory(
    () => OpeningQuantitiesBloc(
      getOpeningQuantities: sl(),
      insertOpeningQuantity: sl(),
      deleteOpeningQuantity: sl(),
      getInventorys: sl(),
      getWarehouses: sl(),
    ),
  );

  sl.registerFactory(
    () => GoodsCostBloc(
      getGoodsCosts: sl(),
      insertGoodsCost: sl(),
      deleteGoodsCost: sl(),
      getWarehouses: sl(),
    ),
  );

  sl.registerFactory(
    () => StocktakingBloc(getInventorys: sl(), getWarehouses: sl()),
  );

  //============================================================
  // Data Sources
  //============================================================
  sl.registerLazySingleton<InventoryDataSource>(
    () => InventoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InventorySubcategoryDataSource>(
    () => InventorySubcategoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InventoryTransactionDataSource>(
    () => InventoryTransactionLocalDataSourceImpl(
      sl(),
      (order) => {
        if (order.id > 0) InventoryTransactionsOrdersTable.id: order.id,
        InventoryTransactionsOrdersTable.inventoryId: order.inventoryId,
        InventoryTransactionsOrdersTable.countUnits: order.countUnits,
        InventoryTransactionsOrdersTable.tranId: order.tranId,
        InventoryTransactionsOrdersTable.transactionType: order.transactionType.name,
      },
    ),
  );
  sl.registerLazySingleton<InventoryTransactionOrderDataSource>(
    () => InventoryTransactionOrderLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OpeningQuantityDataSource>(
    () => OpeningQuantityLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GoodsCostDataSource>(
    () => GoodsCostLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WarehouseValueDataSource>(
    () => WarehouseValueLocalDataSourceImpl(sl()),
  );

  //============================================================
  // Repositories
  //============================================================
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<InventorySubcategoryRepository>(
    () => InventorySubcategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<InventoryTransactionRepository>(
    () => InventoryTransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<InventoryTransactionOrderRepository>(
    () => InventoryTransactionOrderRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<OpeningQuantityRepository>(
    () => OpeningQuantityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GoodsCostRepository>(
    () => GoodsCostRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WarehouseValueRepository>(
    () => WarehouseValueRepositoryImpl(sl()),
  );

  //============================================================
  // Use Cases
  //============================================================
  // Inventory
  sl.registerLazySingleton(() => GetInventorysUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertInventoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventoryUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereCategoryUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereCategoryAndStoreUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryUseCase(sl()));

  // Subcategories (Catalog)
  sl.registerLazySingleton(() => GetInventorySubcategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetInventorySubcategoryByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertInventorySubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventorySubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventorySubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => FirstWhereStoreAndCategoryUseCase(sl()));

  // Batches usecases removed

  // Transactions
  sl.registerLazySingleton(() => GetInventoryTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryTransactionByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertInventoryTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventoryTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventoryTransactionUseCase(sl()));
  // sl.registerLazySingleton(() => GetInventoryTransactionsByTypeUseCase(sl()));

  // Transaction Orders
  sl.registerLazySingleton(() => GetInventoryTransactionOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryTransactionOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertInventoryTransactionOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventoryTransactionOrderUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventoryTransactionOrderUseCase(sl()));
  // sl.registerLazySingleton(() => GetOrdersByTransactionIdUseCase(sl()));

  // Opening Quantities
  sl.registerLazySingleton(() => GetOpeningQuantitysUseCase(sl()));
  sl.registerLazySingleton(() => GetOpeningQuantityByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertOpeningQuantityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOpeningQuantityUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOpeningQuantityUseCase(sl()));
  // sl.registerLazySingleton(() => GetOpeningQuantitySumUseCase(sl()));

  // Goods Cost
  sl.registerLazySingleton(() => GetGoodsCostsUseCase(sl()));
  sl.registerLazySingleton(() => GetGoodsCostByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertGoodsCostUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGoodsCostUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGoodsCostUseCase(sl()));

  // Warehouse Value
  sl.registerLazySingleton(() => GetWarehouseValuesUseCase(sl()));
  sl.registerLazySingleton(() => GetWarehouseValueByIdUseCase(sl()));
  sl.registerLazySingleton(() => InsertWarehouseValueUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWarehouseValueUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWarehouseValueUseCase(sl()));
  // sl.registerLazySingleton(() => FirstWhereWarehouseAndAccountUseCase(sl()));
  // sl.registerLazySingleton(() => GetWarehouseValueByTypeUseCase(sl()));

  // Warehouses
  sl.registerLazySingleton(() => GetWarehousesUseCase(sl()));
  sl.registerLazySingleton(() => InsertWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => GetByCodeUseCase(sl()));
}
