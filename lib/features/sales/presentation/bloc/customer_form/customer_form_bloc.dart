import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'customer_form_event.dart';
import 'customer_form_state.dart';

class CustomerFormBloc extends Bloc<CustomerFormEvent, CustomerFormState> {
  CustomerFormBloc({PersonEntity? initialPerson})
      : super(
          initialPerson != null
              ? CustomerFormState(
                  id: initialPerson.id,
                  personType: initialPerson.personType,
                  personName: initialPerson.personName,
                  phoneNumber: initialPerson.phoneNumber,
                  address: initialPerson.address,
                  email: initialPerson.email,
                  receivableAccountId: initialPerson.receivableAccountId,
                  payableAccountId: initialPerson.payableAccountId,
                  createdAt: initialPerson.createdAt,
                  status: CustomerFormStatus.ready,
                )
              : const CustomerFormState(),
        ) {
    on<InitCustomerForm>(_onInit);
    on<ChangePersonNameEvent>(_onChangePersonName);
    on<ChangePhoneNumberEvent>(_onChangePhoneNumber);
    on<ChangeAddressEvent>(_onChangeAddress);
    on<ChangeEmailEvent>(_onChangeEmail);
    on<ChangeReceivableAccountIdEvent>(_onChangeReceivableAccountId);
    on<ChangePayableAccountIdEvent>(_onChangePayableAccountId);
    on<SaveCustomerEvent>(_onSaveCustomer);
  }

  FutureOr<void> _onInit(
    InitCustomerForm event,
    Emitter<CustomerFormState> emit,
  ) {
    if (event.person != null) {
      emit(
        CustomerFormState(
          id: event.person!.id,
          personType: event.person!.personType,
          personName: event.person!.personName,
          phoneNumber: event.person!.phoneNumber,
          address: event.person!.address,
          email: event.person!.email,
          receivableAccountId: event.person!.receivableAccountId,
          payableAccountId: event.person!.payableAccountId,
          createdAt: event.person!.createdAt,
          status: CustomerFormStatus.ready,
        ),
      );
    } else {
      emit(const CustomerFormState());
    }
  }

  FutureOr<void> _onChangePersonName(
    ChangePersonNameEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(personName: event.personName, status: CustomerFormStatus.ready));
  }

  FutureOr<void> _onChangePhoneNumber(
    ChangePhoneNumberEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber, status: CustomerFormStatus.ready));
  }

  FutureOr<void> _onChangeAddress(
    ChangeAddressEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(address: event.address, status: CustomerFormStatus.ready));
  }

  FutureOr<void> _onChangeEmail(
    ChangeEmailEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: CustomerFormStatus.ready));
  }

  FutureOr<void> _onChangeReceivableAccountId(
    ChangeReceivableAccountIdEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(receivableAccountId: event.receivableAccountId, status: CustomerFormStatus.ready));
  }

  FutureOr<void> _onChangePayableAccountId(
    ChangePayableAccountIdEvent event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(payableAccountId: event.payableAccountId, status: CustomerFormStatus.ready));
  }

  Future<void> _onSaveCustomer(
    SaveCustomerEvent event,
    Emitter<CustomerFormState> emit,
  ) async {
    if (state.personName.trim().isEmpty) {
      emit(state.copyWith(
        status: CustomerFormStatus.failure,
        messageError: 'يرجى إدخال اسم العميل',
      ));
      return;
    }

    emit(state.copyWith(status: CustomerFormStatus.saving));
    final entity = state.toEntity();

    emit(state.copyWith(
      status: CustomerFormStatus.saved,
      createdAt: entity.createdAt,
      messageError: null,
    ));
  }
}
