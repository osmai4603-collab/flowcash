import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_event.dart';

part 'bill_form_event.dart';
part 'bill_form_state.dart';

class BillFormBloc extends Bloc<BillFormEvent, BillFormState> {
  final InsertBillUseCase addBill;
  final UpdateBillUseCase updateBill;

  BillFormBloc({required this.addBill, required this.updateBill}) : super(BillFormInitial()) {
    on<SubmitBillEvent>(_onSubmit);
    on<UpdateBillEvent>(_onUpdate);
    on<InitBillFormEvent>(_onInit);
  }

  Future<void> _onSubmit(
    SubmitBillEvent event,
    Emitter<BillFormState> emit,
  ) async {
    
    emit(BillFormLoading());
    final result = await addBill(event.bill);
    result.fold(
      (failure) => emit(BillFormFailure(message: failure.message)),
      (bill) => emit(BillFormSuccess(bill: bill)),
    );
  }

  Future<void> _onUpdate(
    UpdateBillEvent event,
    Emitter<BillFormState> emit,
  ) async {
    emit(BillFormLoading());
    final result = await updateBill(event.bill);
    result.fold(
      (failure) => emit(BillFormFailure(message: failure.message)),
      (bill) => emit(BillFormSuccess(bill: bill)),
    );
  }

  FutureOr<void> _onInit(InitBillFormEvent event, Emitter<BillFormState> emit) {
    if (event.saleBill != null) {
      emit(BillFormSuccess(bill: event.saleBill!));
    } else {
      emit(BillFormInitial());
    }
  }
}
