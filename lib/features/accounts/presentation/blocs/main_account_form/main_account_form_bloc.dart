import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/system/domain/usecases/currency_usecases.dart';
import 'main_account_form_event.dart';
import 'main_account_form_state.dart';

class MainAccountFormBloc extends Bloc<MainAccountFormEvent, MainAccountFormState> {
  final InsertMainAccountUseCase _insertMainAccount;
  final UpdateMainAccountUseCase _updateMainAccount;
  final GetMaxAccountNumberUseCase _getMaxAccountNumber;
  final GetCurrenciesUseCase _getCurrencies;

  MainAccountFormBloc({
    required InsertMainAccountUseCase insertMainAccount,
    required UpdateMainAccountUseCase updateMainAccount,
    required GetMaxAccountNumberUseCase getMaxAccountNumber,
    required GetCurrenciesUseCase getCurrencies,
  })  : _insertMainAccount = insertMainAccount,
        _updateMainAccount = updateMainAccount,
        _getMaxAccountNumber = getMaxAccountNumber,
        _getCurrencies = getCurrencies,
        super(MainAccountFormState.initial()) {
    on<InitMainAccountForm>(_onInitMainAccountForm);
    on<MainAccountNameChanged>(_onMainAccountNameChanged);
    on<MainAccountGroupChanged>(_onMainAccountGroupChanged);
    on<MainAccountTypeChanged>(_onMainAccountTypeChanged);
    on<MainAccountCurrencyChanged>(_onMainAccountCurrencyChanged);
    on<SubmitMainAccountForm>(_onSubmitMainAccountForm);
  }

  Future<void> _onInitMainAccountForm(
    InitMainAccountForm event,
    Emitter<MainAccountFormState> emit,
  ) async {
    emit(state.copyWith(status: MainAccountFormStatus.loading));
    final currenciesResult = await _getCurrencies();

    await Future.delayed(const Duration(seconds: 1));

    currenciesResult.fold(
      (failure) {
        emit(state.copyWith(
          status: MainAccountFormStatus.failure,
          currencyErrorMessage: failure.message,
        ));
      },
      (currencies) {
        CurrencyEntity? selectedCurrency;
        if (event.editingAccount != null && event.editingAccount!.currencyId != null) {
          final matches = currencies.where(
            (currency) => currency.id == event.editingAccount!.currencyId,
          );
          if (matches.isNotEmpty) {
            selectedCurrency = matches.first;
          }
        }

        if (selectedCurrency == null && currencies.isNotEmpty) {
          selectedCurrency = currencies.firstWhere(
            (currency) => currency.isDefault,
            orElse: () => currencies.first,
          );
        }

        if (event.editingAccount != null) {
          final acc = event.editingAccount!;
          emit(MainAccountFormState(
            status: MainAccountFormStatus.initial,
            editingAccount: acc,
            accountName: acc.accountName,
            accountNumber: acc.accountNumber,
            selectedGroup: acc.mainAccountType.accountType,
            selectedType: acc.mainAccountType,
            selectedCurrency: selectedCurrency,
            currencies: currencies,
            currencyErrorMessage: null,
          ));
        } else {
          emit(MainAccountFormState(
            status: MainAccountFormStatus.initial,
            accountName: '',
            accountNumber: '',
            selectedCurrency: selectedCurrency,
            currencies: currencies,
            currencyErrorMessage: null,
          ));
        }
      },
    );
  }

  void _onMainAccountNameChanged(
    MainAccountNameChanged event,
    Emitter<MainAccountFormState> emit,
  ) {
    emit(state.copyWith(accountName: event.name));
  }

  Future<void> _onMainAccountGroupChanged(
    MainAccountGroupChanged event,
    Emitter<MainAccountFormState> emit,
  ) async {
    emit(state.copyWith(status: MainAccountFormStatus.loading));
    final res = await _getMaxAccountNumber(event.group);

    res.fold(
      (failure) => emit(state.copyWith(
        status: MainAccountFormStatus.failure,
        errorMessage: failure.message,
      )),
      (maxNum) {
        final nextNum = maxNum != null ? maxNum + 1 : int.parse('${event.group.accountNumber}01');
        emit(state.copyWith(
          status: MainAccountFormStatus.initial,
          selectedGroup: event.group,
          selectedType: null, // Clear type to enforce re-selection
          accountNumber: nextNum.toString(),
        ));
      },
    );
  }

  void _onMainAccountTypeChanged(
    MainAccountTypeChanged event,
    Emitter<MainAccountFormState> emit,
  ) {
    emit(state.copyWith(selectedType: event.type));
  }

  void _onMainAccountCurrencyChanged(
    MainAccountCurrencyChanged event,
    Emitter<MainAccountFormState> emit,
  ) {
    emit(state.copyWith(selectedCurrency: event.currency));
  }

  Future<void> _onSubmitMainAccountForm(
    SubmitMainAccountForm event,
    Emitter<MainAccountFormState> emit,
  ) async {
    if (state.accountName.isEmpty) {
      emit(state.copyWith(errorMessage: 'اسم الحساب مطلوب'));
      return;
    }
    if (state.selectedGroup == null) {
      emit(state.copyWith(errorMessage: 'مجموعة الحساب مطلوبة'));
      return;
    }
    if (state.selectedType == null) {
      emit(state.copyWith(errorMessage: 'نوع الحساب مطلوب'));
      return;
    }
    if (state.selectedCurrency == null) {
      emit(state.copyWith(errorMessage: 'العملة مطلوبة'));
      return;
    }

    emit(state.copyWith(status: MainAccountFormStatus.loading));
    await Future.delayed(const Duration(seconds: 1));

    if (state.editingAccount != null) {
      final updated = state.editingAccount!.copyWith(
        accountName: state.accountName,
        currencyId: state.selectedCurrency!.id,
        mainAccountType: state.selectedType!,
      );
      final res = await _updateMainAccount(updated);
      res.fold(
        (failure) => emit(state.copyWith(
          status: MainAccountFormStatus.failure,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(status: MainAccountFormStatus.success)),
      );
    } else {
      final newAccount = MainAccountEntity(
        id: 0,
        accountName: state.accountName,
        accountNumber: state.accountNumber,
        currencyId: state.selectedCurrency!.id,
        mainAccountType: state.selectedType!,
      );
      final res = await _insertMainAccount(newAccount);
      res.fold(
        (failure) => emit(state.copyWith(
          status: MainAccountFormStatus.failure,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(status: MainAccountFormStatus.success)),
      );
    }
  }
}
