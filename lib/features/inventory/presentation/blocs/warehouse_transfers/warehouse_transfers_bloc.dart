import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_transaction_order_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'warehouse_transfers_event.dart';
import 'warehouse_transfers_state.dart';

class WarehouseTransfersBloc extends Bloc<WarehouseTransfersEvent, WarehouseTransfersState> {
  final GetInventoryTransactionsUseCase _getTransactions;
  final InsertInventoryTransactionUseCase _insertTransaction;
  final DeleteInventoryTransactionUseCase _deleteTransaction;
  final GetInventoryTransactionOrdersUseCase _getTransactionOrders;
  final InsertInventoryTransactionOrderUseCase _insertOrder;
  final DeleteInventoryTransactionOrderUseCase _deleteOrder;
  final GetWarehousesUseCase _getWarehouses;

  WarehouseTransfersBloc({
    required GetInventoryTransactionsUseCase getTransactions,
    required InsertInventoryTransactionUseCase insertTransaction,
    required DeleteInventoryTransactionUseCase deleteTransaction,
    required GetInventoryTransactionOrdersUseCase getTransactionOrders,
    required InsertInventoryTransactionOrderUseCase insertOrder,
    required DeleteInventoryTransactionOrderUseCase deleteOrder,
    required GetWarehousesUseCase getWarehouses,
  })  : _getTransactions = getTransactions,
        _insertTransaction = insertTransaction,
        _deleteTransaction = deleteTransaction,
        _getTransactionOrders = getTransactionOrders,
        _insertOrder = insertOrder,
      _deleteOrder = deleteOrder,
        _getWarehouses = getWarehouses,
        super(const WarehouseTransfersState()) {
    on<LoadTransfersEvent>(_onLoadTransfers);
    on<AddTransferEvent>(_onAddTransfer);
    on<DeleteTransferEvent>(_onDeleteTransfer);
  }

  Future<void> _onLoadTransfers(
    LoadTransfersEvent event,
    Emitter<WarehouseTransfersState> emit,
  ) async {
    emit(state.toLoading());

    final tRes = await _getTransactions();
    final oRes = await _getTransactionOrders();
    final wRes = await _getWarehouses();

    tRes.fold(
      (f) => emit(state.toError(f.message)),
      (transList) {
        oRes.fold(
          (f) => emit(state.toError(f.message)),
          (ordersList) {
            wRes.fold(
              (f) => emit(state.toError(f.message)),
              (warehousesList) {
                emit(state.copyWith(
                  status: TransfersStatus.success,
                  transactions: transList,
                  allOrders: ordersList,
                  warehouses: warehousesList,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onAddTransfer(
    AddTransferEvent event,
    Emitter<WarehouseTransfersState> emit,
  ) async {
    // 1. Insert "From" Warehouse Transaction (Delivery / Outward)
    final fromRes = await _insertTransaction(event.fromTransaction);
    await fromRes.fold(
      (f) async => emit(state.toError(f.message)),
      (fromT) async {
        // 2. Insert "To" Warehouse Transaction (Receipt / Inward)
        final toRes = await _insertTransaction(event.toTransaction);
        await toRes.fold(
          (f) async => emit(state.toError(f.message)),
          (toT) async {
            final List<InventoryTransactionOrderEntity> insertedOrders = [];
            
            // 3. Insert items for From Transaction
            for (var item in event.items) {
              final oRes = await _insertOrder(item.copyWith(tranId: fromT.id));
              oRes.fold(
                (f) => emit(state.toError(f.message)),
                (newOrder) => insertedOrders.add(newOrder),
              );
            }

            // 4. Insert items for To Transaction
            for (var item in event.items) {
              final oRes = await _insertOrder(item.copyWith(tranId: toT.id));
              oRes.fold(
                (f) => emit(state.toError(f.message)),
                (newOrder) => insertedOrders.add(newOrder),
              );
            }

            emit(state.addTransfer(fromT, toT, insertedOrders));
          },
        );
      },
    );
  }

  Future<void> _onDeleteTransfer(
    DeleteTransferEvent event,
    Emitter<WarehouseTransfersState> emit,
  ) async {
    // Delete orders for both transactions
    final oldOrders = state.allOrders.where((o) => o.tranId == event.fromId || o.tranId == event.toId).toList();
    for (var o in oldOrders) {
      await _deleteOrder(o.id);
    }

    // Delete both transactions
    await _deleteTransaction(event.fromId);
    await _deleteTransaction(event.toId);
    
    emit(state.removeTransfer(event.fromId, event.toId));
  }
}
