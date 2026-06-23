import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/usecases/person_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'customers_page_event.dart';
import 'customers_page_state.dart';

class CustomersPageBloc extends Bloc<CustomersPageEvent, CustomersPageState> {
  final GetPersonsUseCase _getPersonsUseCase;
  final GetSubAccountsUseCase _getSubAccountsUseCase;
  final InsertPersonUseCase _insertPersonUseCase;

  final List<PersonEntity> _allPersons = [];
  final List<SubAccountEntity> _subAccounts = [];

  CustomersPageBloc({
    GetPersonsUseCase? getPersonsUseCase,
    GetSubAccountsUseCase? getSubAccountsUseCase,
    InsertPersonUseCase? insertPersonUseCase,
  })  : _getPersonsUseCase = getPersonsUseCase ?? GetIt.instance<GetPersonsUseCase>(),
        _getSubAccountsUseCase = getSubAccountsUseCase ?? GetIt.instance<GetSubAccountsUseCase>(),
        _insertPersonUseCase = insertPersonUseCase ?? GetIt.instance<InsertPersonUseCase>(),
        super(CustomersPageInitial()) {
    on<LoadCustomersPageEvent>(_onLoad);
    on<SearchCustomersPageEvent>(_onSearch);
    on<AddCustomerEvent>(_onAddCustomer);
  }

  Future<void> _onLoad(
    LoadCustomersPageEvent event,
    Emitter<CustomersPageState> emit,
  ) async {
    emit(CustomersPageLoadInProgress());

    final personsRes = await _getPersonsUseCase();
    final subAccountsRes = await _getSubAccountsUseCase();

    personsRes.fold(
      (failure) => emit(CustomersPageOperationFailure(failure.message)),
      (personsList) {
        subAccountsRes.fold(
          (failure) => emit(CustomersPageOperationFailure(failure.message)),
          (subAccountsList) {
            _allPersons.clear();
            _allPersons.addAll(personsList);

            _subAccounts.clear();
            _subAccounts.addAll(subAccountsList);

            emit(CustomersPageLoadSuccess(
              persons: List.of(_allPersons),
              subAccounts: List.of(_subAccounts),
            ));
          },
        );
      },
    );
  }

  Future<void> _onSearch(
    SearchCustomersPageEvent event,
    Emitter<CustomersPageState> emit,
  ) async {
    if (state is CustomersPageLoadSuccess) {
      final query = event.query.trim().toLowerCase();
      if (query.isEmpty) {
        emit(CustomersPageLoadSuccess(
          persons: List.of(_allPersons),
          subAccounts: List.of(_subAccounts),
          query: event.query,
        ));
        return;
      }

      final filtered = _allPersons.where((person) {
        return person.personName.toLowerCase().contains(query) ||
            (person.phoneNumber?.toLowerCase().contains(query) ?? false) ||
            (person.address?.toLowerCase().contains(query) ?? false) ||
            (person.email?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(CustomersPageLoadSuccess(
        persons: filtered,
        subAccounts: List.of(_subAccounts),
        query: event.query,
      ));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomersPageState> emit,
  ) async {
    final result = await _insertPersonUseCase(event.person);
    result.fold(
      (failure) => emit(CustomersPageOperationFailure(failure.message)),
      (newPerson) {
        _allPersons.insert(0, newPerson);

        String currentQuery = '';
        if (state is CustomersPageLoadSuccess) {
          currentQuery = (state as CustomersPageLoadSuccess).query;
        }

        final query = currentQuery.trim().toLowerCase();
        final filtered = query.isEmpty
            ? List<PersonEntity>.of(_allPersons)
            : _allPersons.where((person) {
                return person.personName.toLowerCase().contains(query) ||
                    (person.phoneNumber?.toLowerCase().contains(query) ?? false) ||
                    (person.address?.toLowerCase().contains(query) ?? false) ||
                    (person.email?.toLowerCase().contains(query) ?? false);
              }).toList();

        emit(CustomersPageLoadSuccess(
          persons: filtered,
          subAccounts: List.of(_subAccounts),
          query: currentQuery,
        ));
      },
    );
  }
}
