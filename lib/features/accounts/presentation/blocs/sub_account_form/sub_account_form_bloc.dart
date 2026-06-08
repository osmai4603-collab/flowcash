import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/system/domain/usecases/currency_usecases.dart';
import 'sub_account_form_event.dart';
import 'sub_account_form_state.dart';

class SubAccountFormBloc
    extends Bloc<SubAccountFormEvent, SubAccountFormState> {
  final InsertSubAccountUseCase _insertSubAccount;
  final UpdateSubAccountUseCase _updateSubAccount;
  final GetMainAccountByIdUseCase _getMainAccountById;
  final UpdateCounterUseCase _updateCounter;
  final GetCurrenciesUseCase _getCurrencies;

  SubAccountFormBloc({
    required InsertSubAccountUseCase insertSubAccount,
    required UpdateSubAccountUseCase updateSubAccount,
    required GetMainAccountByIdUseCase getMainAccountById,
    required UpdateCounterUseCase updateCounter,
    required GetCurrenciesUseCase getCurrencies,
  }) : _insertSubAccount = insertSubAccount,
       _updateSubAccount = updateSubAccount,
       _getMainAccountById = getMainAccountById,
       _updateCounter = updateCounter,
       _getCurrencies = getCurrencies,
       super(SubAccountFormState.initial(0)) {
    on<InitSubAccountForm>(_onInitSubAccountForm);
    on<SubAccountNameChanged>(_onSubAccountNameChanged);
    on<SubAccountTypeChanged>(_onSubAccountTypeChanged);
    on<SubAccountCurrencyChanged>(_onSubAccountCurrencyChanged);
    on<SubAccountBalanceMaxChanged>(_onSubAccountBalanceMaxChanged);
    on<SubmitSubAccountForm>(_onSubmitSubAccountForm);
  }

  Future<void> _onInitSubAccountForm(
    InitSubAccountForm event,
    Emitter<SubAccountFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SubAccountFormStatus.loading,
        mainAccountId: event.mainAccountId,
      ),
    );

    final currenciesResult = await _getCurrencies();
    await Future.delayed(const Duration(seconds: 1));

    if (currenciesResult.isLeft()) {
      currenciesResult.fold(
        (failure) => emit(
          state.copyWith(
            status: SubAccountFormStatus.failure,
            currencyErrorMessage: failure.message,
          ),
        ),
        (_) {},
      );
      return;
    }

    final currencies = currenciesResult.fold(
      (_) => <CurrencyEntity>[],
      (currencies) => currencies,
    );

    final parentRes = await _getMainAccountById(event.mainAccountId);

    parentRes.fold(
      (failure) => emit(
        state.copyWith(
          status: SubAccountFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (parent) {
        if (parent == null) {
          emit(
            state.copyWith(
              status: SubAccountFormStatus.failure,
              errorMessage: 'الحساب الرئيسي غير موجود',
            ),
          );
          return;
        }

        CurrencyEntity? selectedCurrency;
        if (event.editingSubAccount != null) {
          final matches = currencies.where(
            (currency) => currency.id == event.editingSubAccount!.currencyId,
          );
          if (matches.isNotEmpty) {
            selectedCurrency = matches.first;
          }
        }

        if (selectedCurrency == null && parent.currencyId != null) {
          final matches = currencies.where(
            (currency) => currency.id == parent.currencyId,
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

        final subaccountsTypes = SubAccountType.whereMainAccountType(
          parent.mainAccountType,
        );

        if (event.editingSubAccount != null) {
          final sub = event.editingSubAccount!;
          emit(
            SubAccountFormState(
              status: SubAccountFormStatus.initial,
              editingSubAccount: sub,
              mainAccountId: event.mainAccountId,
              parentMainAccount: parent,
              accountName: sub.accountName,
              accountNumber: sub.accountNumber,
              subAccountTypes: subaccountsTypes,
              selectedType: subaccountsTypes.firstWhere(
                (type) => type.name == sub.subAccountType.name,
              ),
              selectedCurrency: selectedCurrency,
              currencies: currencies,
              balanceMax: sub.balanceMax,
            ),
          );
        } else {
          final counter = parent.numbersCounter;
          final serial = counter.toString().padLeft(3, '0');
          final generatedNumber = '${parent.accountNumber}$serial';

          emit(
            SubAccountFormState(
              status: SubAccountFormStatus.initial,
              mainAccountId: event.mainAccountId,
              parentMainAccount: parent,
              accountName: '',
              accountNumber: generatedNumber,
              selectedCurrency: selectedCurrency,
              currencies: currencies,
              subAccountTypes: subaccountsTypes,
              selectedType: subaccountsTypes.isNotEmpty
                  ? subaccountsTypes.first
                  : null,
            ),
          );
        }
      },
    );
  }

  void _onSubAccountNameChanged(
    SubAccountNameChanged event,
    Emitter<SubAccountFormState> emit,
  ) {
    emit(state.copyWith(accountName: event.name));
  }

  void _onSubAccountTypeChanged(
    SubAccountTypeChanged event,
    Emitter<SubAccountFormState> emit,
  ) {
    emit(state.copyWith(selectedType: event.type));
  }

  void _onSubAccountCurrencyChanged(
    SubAccountCurrencyChanged event,
    Emitter<SubAccountFormState> emit,
  ) {
    emit(state.copyWith(selectedCurrency: event.currency));
  }

  void _onSubAccountBalanceMaxChanged(
    SubAccountBalanceMaxChanged event,
    Emitter<SubAccountFormState> emit,
  ) {
    if (event.balanceMax == null) {
      emit(state.copyWith(clearBalanceMax: true));
    } else {
      emit(state.copyWith(balanceMax: event.balanceMax));
    }
  }

  Future<void> _onSubmitSubAccountForm(
    SubmitSubAccountForm event,
    Emitter<SubAccountFormState> emit,
  ) async {
    if (state.accountName.isEmpty) {
      emit(state.copyWith(errorMessage: 'اسم الحساب مطلوب'));
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

    emit(state.copyWith(status: SubAccountFormStatus.loading));
    await Future.delayed(const Duration(seconds: 1));

    if (state.editingSubAccount != null) {
      final updated = state.editingSubAccount!.copyWith(
        accountName: state.accountName,
        currencyId: state.selectedCurrency!.id,
        subAccountType: state.selectedType!,
        balanceMax: state.balanceMax,
      );
      final res = await _updateSubAccount(updated);
      res.fold(
        (failure) => emit(
          state.copyWith(
            status: SubAccountFormStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) => emit(state.copyWith(status: SubAccountFormStatus.success)),
      );
    } else {
      final newSub = SubAccountEntity(
        id: 0,
        mainAccountId: state.mainAccountId,
        accountName: state.accountName,
        accountNumber: state.accountNumber,
        currencyId: state.selectedCurrency!.id,
        subAccountType: state.selectedType!,
        balanceMax: state.balanceMax,
        createdAt: DateTime.now(),
      );

      final res = await _insertSubAccount(newSub);
      await res.fold(
        (failure) async => emit(
          state.copyWith(
            status: SubAccountFormStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) async {
          if (state.parentMainAccount != null) {
            await _updateCounter(
              counter: state.parentMainAccount!.numbersCounter + 1,
              id: state.parentMainAccount!.id,
            );
          }
          emit(state.copyWith(status: SubAccountFormStatus.success));
        },
      );
    }
  }
}
