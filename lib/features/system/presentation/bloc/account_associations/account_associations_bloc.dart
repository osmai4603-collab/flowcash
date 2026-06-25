import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/usecases/person_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'account_associations_event.dart';
import 'account_associations_state.dart';

class AccountAssociationsBloc extends Bloc<AccountAssociationsEvent, AccountAssociationsState> {
  final GetPersonsUseCase _getPersonsUseCase;
  final GetSubAccountsUseCase _getSubAccountsUseCase;
  final InsertPersonUseCase _insertPersonUseCase;
  final UpdatePersonUseCase _updatePersonUseCase;
  final DeletePersonUseCase _deletePersonUseCase;

  final List<PersonEntity> _allPersons = [];
  final List<SubAccountEntity> _subAccounts = [];

  AccountAssociationsBloc({
    GetPersonsUseCase? getPersonsUseCase,
    GetSubAccountsUseCase? getSubAccountsUseCase,
    InsertPersonUseCase? insertPersonUseCase,
    UpdatePersonUseCase? updatePersonUseCase,
    DeletePersonUseCase? deletePersonUseCase,
  })  : _getPersonsUseCase = getPersonsUseCase ?? GetIt.instance<GetPersonsUseCase>(),
        _getSubAccountsUseCase = getSubAccountsUseCase ?? GetIt.instance<GetSubAccountsUseCase>(),
        _insertPersonUseCase = insertPersonUseCase ?? GetIt.instance<InsertPersonUseCase>(),
        _updatePersonUseCase = updatePersonUseCase ?? GetIt.instance<UpdatePersonUseCase>(),
        _deletePersonUseCase = deletePersonUseCase ?? GetIt.instance<DeletePersonUseCase>(),
        super(AccountAssociationsInitial()) {
    on<LoadAccountAssociationsEvent>(_onLoad);
    on<SearchAccountAssociationsEvent>(_onSearch);
    on<AddAccountAssociationEvent>(_onAddAssociation);
    on<UpdateAccountAssociationEvent>(_onUpdateAssociation);
    on<DeleteAccountAssociationEvent>(_onDeleteAssociation);
  }

  Future<void> _onLoad(
    LoadAccountAssociationsEvent event,
    Emitter<AccountAssociationsState> emit,
  ) async {
    emit(AccountAssociationsLoadInProgress());

    final personsRes = await _getPersonsUseCase();
    final subAccountsRes = await _getSubAccountsUseCase();

    personsRes.fold(
      (failure) => emit(AccountAssociationsOperationFailure(failure.message)),
      (personsList) {
        subAccountsRes.fold(
          (failure) => emit(AccountAssociationsOperationFailure(failure.message)),
          (subAccountsList) {
            _allPersons.clear();
            _allPersons.addAll(personsList);

            _subAccounts.clear();
            _subAccounts.addAll(subAccountsList);

            emit(AccountAssociationsLoadSuccess(
              persons: List.of(_allPersons),
              subAccounts: List.of(_subAccounts),
            ));
          },
        );
      },
    );
  }

  Future<void> _onSearch(
    SearchAccountAssociationsEvent event,
    Emitter<AccountAssociationsState> emit,
  ) async {
    if (state is AccountAssociationsLoadSuccess) {
      final query = event.query.trim().toLowerCase();
      if (query.isEmpty) {
        emit(AccountAssociationsLoadSuccess(
          persons: List.of(_allPersons),
          subAccounts: List.of(_subAccounts),
          query: event.query,
        ));
        return;
      }

      final filtered = _allPersons.where((person) {
        return person.personName.toLowerCase().contains(query) ||
            person.personType.displayName().toLowerCase().contains(query) ||
            (person.phoneNumber?.toLowerCase().contains(query) ?? false) ||
            (person.address?.toLowerCase().contains(query) ?? false) ||
            (person.email?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(AccountAssociationsLoadSuccess(
        persons: filtered,
        subAccounts: List.of(_subAccounts),
        query: event.query,
      ));
    }
  }

  Future<void> _onAddAssociation(
    AddAccountAssociationEvent event,
    Emitter<AccountAssociationsState> emit,
  ) async {
    final result = await _insertPersonUseCase(event.person);
    result.fold(
      (failure) => emit(AccountAssociationsOperationFailure(failure.message)),
      (newPerson) {
        _allPersons.insert(0, newPerson);
        _refreshState(emit);
      },
    );
  }

  Future<void> _onUpdateAssociation(
    UpdateAccountAssociationEvent event,
    Emitter<AccountAssociationsState> emit,
  ) async {
    final result = await _updatePersonUseCase(event.person);
    result.fold(
      (failure) => emit(AccountAssociationsOperationFailure(failure.message)),
      (updatedPerson) {
        final index = _allPersons.indexWhere((p) => p.id == updatedPerson.id);
        if (index != -1) {
          _allPersons[index] = updatedPerson;
        }
        _refreshState(emit);
      },
    );
  }

  Future<void> _onDeleteAssociation(
    DeleteAccountAssociationEvent event,
    Emitter<AccountAssociationsState> emit,
  ) async {
    final result = await _deletePersonUseCase(event.id);
    result.fold(
      (failure) => emit(AccountAssociationsOperationFailure(failure.message)),
      (success) {
        _allPersons.removeWhere((p) => p.id == event.id);
        _refreshState(emit);
      },
    );
  }

  void _refreshState(Emitter<AccountAssociationsState> emit) {
    String currentQuery = '';
    if (state is AccountAssociationsLoadSuccess) {
      currentQuery = (state as AccountAssociationsLoadSuccess).query;
    }

    final query = currentQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<PersonEntity>.of(_allPersons)
        : _allPersons.where((person) {
            return person.personName.toLowerCase().contains(query) ||
                person.personType.displayName().toLowerCase().contains(query) ||
                (person.phoneNumber?.toLowerCase().contains(query) ?? false) ||
                (person.address?.toLowerCase().contains(query) ?? false) ||
                (person.email?.toLowerCase().contains(query) ?? false);
          }).toList();

    emit(AccountAssociationsLoadSuccess(
      persons: filtered,
      subAccounts: List.of(_subAccounts),
      query: currentQuery,
    ));
  }
}
