import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_order_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetInventoryTransactionsUseCase _getTransactions;
  final InsertInventoryTransactionUseCase _insertTransaction;
  final UpdateInventoryTransactionUseCase _updateTransaction;
  final DeleteInventoryTransactionUseCase _deleteTransaction;
  final GetInventoryTransactionOrdersUseCase _getTransactionOrders;
  final InsertInventoryTransactionOrderUseCase _insertOrder;
  final DeleteInventoryTransactionOrderUseCase _deleteOrder;
  final GetWarehousesUseCase _getWarehouses;

  TransactionsBloc({
    required GetInventoryTransactionsUseCase getTransactions,
    required InsertInventoryTransactionUseCase insertTransaction,
    required UpdateInventoryTransactionUseCase updateTransaction,
    required DeleteInventoryTransactionUseCase deleteTransaction,
    required GetInventoryTransactionOrdersUseCase getTransactionOrders,
    required InsertInventoryTransactionOrderUseCase insertOrder,
    required DeleteInventoryTransactionOrderUseCase deleteOrder,
    required GetWarehousesUseCase getWarehouses,
  }) : _getTransactions = getTransactions,
       _insertTransaction = insertTransaction,
       _updateTransaction = updateTransaction,
       _deleteTransaction = deleteTransaction,
       _getTransactionOrders = getTransactionOrders,
       _insertOrder = insertOrder,
       _deleteOrder = deleteOrder,
       _getWarehouses = getWarehouses,
       super(const TransactionsState()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.toLoading());

    final tRes = await _getTransactions();
    final oRes = await _getTransactionOrders();
    final wRes = await _getWarehouses();

    tRes.fold((f) => emit(state.toError(f.message)), (transList) {
      oRes.fold((f) => emit(state.toError(f.message)), (ordersList) {
        wRes.fold((f) => emit(state.toError(f.message)), (warehousesList) {
          emit(
            state.copyWith(
              status: TransactionsStatus.success,
              transactions: transList,
              allOrders: ordersList,
              warehouses: warehousesList,
            ),
          );
        });
      });
    });
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    // 1. Insert transaction
    final tRes = await _insertTransaction(event.transaction);
    await tRes.fold((f) async => emit(state.toError(f.message)), (
      newTran,
    ) async {
      // 2. Insert items with inserted tranId
      final List<InventoryTransactionOrderEntity> insertedOrders = [];
      for (var item in event.items) {
        final orderToInsert = item.copyWith(tranId: newTran.id);
        final oRes = await _insertOrder(orderToInsert);
        oRes.fold(
          (f) => emit(state.toError(f.message)),
          (newOrder) => insertedOrders.add(newOrder),
        );
      }
      emit(state.addTransaction(newTran, insertedOrders));
    });
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    // 1. Update main transaction details
    final tRes = await _updateTransaction(event.transaction);
    await tRes.fold((f) async => emit(state.toError(f.message)), (
      updatedTran,
    ) async {
      // 2. Clear old orders for this transaction in DB
      // Fetch existing orders first
      final oldOrders = state.allOrders
          .where((o) => o.tranId == updatedTran.id)
          .toList();
      for (var o in oldOrders) {
        await _deleteOrder(o.id);
      }

      // 3. Re-insert updated order lines
      final List<InventoryTransactionOrderEntity> newOrders = [];
      for (var item in event.items) {
        final orderToInsert = item.copyWith(tranId: updatedTran.id);
        final oRes = await _insertOrder(orderToInsert);
        oRes.fold(
          (f) => emit(state.toError(f.message)),
          (newOrder) => newOrders.add(newOrder),
        );
      }

      emit(state.updateTransaction(updatedTran, newOrders));
    });
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    // Delete orders first
    final oldOrders = state.allOrders
        .where((o) => o.tranId == event.id)
        .toList();
    for (var o in oldOrders) {
      await _deleteOrder(o.id);
    }

    // Delete transaction
    final result = await _deleteTransaction(event.id);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (_) => emit(state.removeTransaction(event.id)),
    );
  }
}
