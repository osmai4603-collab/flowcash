import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'bills_event.dart';
import 'bills_state.dart';

class BillsBloc extends Bloc<BillsEvent, BillsState> {
  final GetBillsUseCase _getBillsUseCase;
  final InsertBillUseCase _insertBillUseCase;
  final UpdateBillUseCase _updateBillUseCase;
  final DeleteBillUseCase _deleteBillUseCase;

  BillsBloc({
    required GetBillsUseCase getBillsUseCase,
    required InsertBillUseCase insertBillUseCase,
    required UpdateBillUseCase updateBillUseCase,
    required DeleteBillUseCase deleteBillUseCase,
  }) : _getBillsUseCase = getBillsUseCase,
       _insertBillUseCase = insertBillUseCase,
       _updateBillUseCase = updateBillUseCase,
       _deleteBillUseCase = deleteBillUseCase,
       super(const BillsState()) {
    on<LoadBillsEvent>(_onLoadBills);
    on<AddBillEvent>(_onAddBill);
    on<UpdateBillEvent>(_onUpdateBill);
    on<DeleteBillEvent>(_onDeleteBill);
    on<SelectBillEvent>(_onSelectBill);
  }

  Future<void> _onLoadBills(LoadBillsEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _getBillsUseCase();
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (bills) =>
          emit(state.copyWith(bills: bills, status: BillsStatus.success)),
    );
  }

  Future<void> _onAddBill(AddBillEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _insertBillUseCase(
      event.bill.copyWith(orders: event.orders),
    );
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (newBill) => emit(state.addBill(newBill, newBill.orders)),
    );
  }

  Future<void> _onUpdateBill(UpdateBillEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _updateBillUseCase(
      event.bill.copyWith(orders: event.orders),
    );
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (updatedBill) => emit(state.updateBill(updatedBill, updatedBill.orders)),
    );
  }

  Future<void> _onDeleteBill(DeleteBillEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _deleteBillUseCase(event.id);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (_) => emit(state.removeBill(event.id)),
    );
  }

  void _onSelectBill(SelectBillEvent event, EmitFn emit) {
    emit(
      state.copyWith(
        selectedBill: event.bill,
        selectedBillOrders: event.bill?.orders ?? const [],
      ),
    );
  }
}

typedef EmitFn = Emitter<BillsState>;
