import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'account_association_form_event.dart';
import 'account_association_form_state.dart';

class AccountAssociationFormBloc extends Bloc<AccountAssociationFormEvent, AccountAssociationFormState> {
  AccountAssociationFormBloc({PersonEntity? initialPerson})
      : super(
          initialPerson != null
              ? AccountAssociationFormState(
                  id: initialPerson.id,
                  personType: initialPerson.personType,
                  personName: initialPerson.personName,
                  phoneNumber: initialPerson.phoneNumber,
                  address: initialPerson.address,
                  email: initialPerson.email,
                  receivableAccountId: initialPerson.receivableAccountId,
                  payableAccountId: initialPerson.payableAccountId,
                  createdAt: initialPerson.createdAt,
                  status: AccountAssociationFormStatus.ready,
                )
              : const AccountAssociationFormState(),
        ) {
    on<InitAccountAssociationForm>(_onInit);
    on<ChangePersonTypeEvent>(_onChangePersonType);
    on<ChangePersonNameEvent>(_onChangePersonName);
    on<ChangePhoneNumberEvent>(_onChangePhoneNumber);
    on<ChangeAddressEvent>(_onChangeAddress);
    on<ChangeEmailEvent>(_onChangeEmail);
    on<ChangeReceivableAccountIdEvent>(_onChangeReceivableAccountId);
    on<ChangePayableAccountIdEvent>(_onChangePayableAccountId);
    on<SaveAccountAssociationEvent>(_onSaveAssociation);
  }

  FutureOr<void> _onInit(
    InitAccountAssociationForm event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    if (event.person != null) {
      emit(
        AccountAssociationFormState(
          id: event.person!.id,
          personType: event.person!.personType,
          personName: event.person!.personName,
          phoneNumber: event.person!.phoneNumber,
          address: event.person!.address,
          email: event.person!.email,
          receivableAccountId: event.person!.receivableAccountId,
          payableAccountId: event.person!.payableAccountId,
          createdAt: event.person!.createdAt,
          status: AccountAssociationFormStatus.ready,
        ),
      );
    } else {
      emit(const AccountAssociationFormState());
    }
  }

  FutureOr<void> _onChangePersonType(
    ChangePersonTypeEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(personType: event.personType, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangePersonName(
    ChangePersonNameEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(personName: event.personName, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangePhoneNumber(
    ChangePhoneNumberEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangeAddress(
    ChangeAddressEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(address: event.address, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangeEmail(
    ChangeEmailEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangeReceivableAccountId(
    ChangeReceivableAccountIdEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(receivableAccountId: event.receivableAccountId, status: AccountAssociationFormStatus.ready));
  }

  FutureOr<void> _onChangePayableAccountId(
    ChangePayableAccountIdEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) {
    emit(state.copyWith(payableAccountId: event.payableAccountId, status: AccountAssociationFormStatus.ready));
  }

  Future<void> _onSaveAssociation(
    SaveAccountAssociationEvent event,
    Emitter<AccountAssociationFormState> emit,
  ) async {
    if (state.personName.trim().isEmpty) {
      emit(state.copyWith(
        status: AccountAssociationFormStatus.failure,
        messageError: 'يرجى إدخال الاسم',
      ));
      return;
    }

    emit(state.copyWith(status: AccountAssociationFormStatus.saving));
    final entity = state.toEntity();

    emit(state.copyWith(
      status: AccountAssociationFormStatus.saved,
      createdAt: entity.createdAt,
      messageError: null,
    ));
  }
}
