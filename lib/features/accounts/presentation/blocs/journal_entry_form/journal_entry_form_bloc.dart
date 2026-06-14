import 'package:flowcash/core/enums/account_status_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_item_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'journal_entry_form_event.dart';
import 'journal_entry_form_state.dart';

class JournalEntryFormBloc
    extends Bloc<JournalEntryFormEvent, JournalEntryFormState> {
  final InsertJournalEntryUseCase _insertJournalEntryWithItems;
  final GetJournalItemsByEntryIdUseCase _getJournalItemsByEntryId;
  final GetSubAccountsUseCase _getSubAccounts;
  final GetSubAccountByIdUseCase _getSubAccountById;
  final GetMainAccountByIdUseCase _getMainAccountById;
  final GetCurrenciesUseCase _getCurrencies;
  final GetExPriceUseCase _getExPrice;

  JournalEntryFormBloc({
    required InsertJournalEntryUseCase insertJournalEntryWithItems,
    required GetJournalItemsByEntryIdUseCase getJournalItemsByEntryId,
    required UpdateSubaccountBalanceUseCase updateSubaccountBalance,
    required UpdateMainAccountBalanceUseCase updateMainAccountBalance,
    required GetSubAccountsUseCase getSubAccounts,
    required GetSubAccountByIdUseCase getSubAccountById,
    required GetMainAccountByIdUseCase getMainAccountById,
    required GetCurrenciesUseCase getCurrencies,
    required GetExPriceUseCase getExPrice,
  }) : _insertJournalEntryWithItems = insertJournalEntryWithItems,
       _getJournalItemsByEntryId = getJournalItemsByEntryId,
       _getSubAccounts = getSubAccounts,
       _getSubAccountById = getSubAccountById,
       _getMainAccountById = getMainAccountById,
       _getCurrencies = getCurrencies,
       _getExPrice = getExPrice,
       super(JournalEntryFormState.initial()) {
    on<InitJournalEntryForm>(_onInitJournalEntryForm);
    on<JournalEntryDescriptionChanged>(_onJournalEntryDescriptionChanged);
    on<JournalEntryDateChanged>(_onJournalEntryDateChanged);
    on<JournalEntryCurrencyChanged>(_onJournalEntryCurrencyChanged);
    on<AddJournalItemField>(_onAddJournalItemField);
    on<RemoveJournalItemField>(_onRemoveJournalItemField);
    on<JournalItemFieldChanged>(_onJournalItemFieldChanged);
    on<SubmitJournalEntryForm>(_onSubmitJournalEntryForm);
  }

  Future<void> _onInitJournalEntryForm(
    InitJournalEntryForm event,
    Emitter<JournalEntryFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: JournalEntryFormStatus.loading,
        editingEntry: event.editingEntry,
        isLoadingCurrencies: true,
      ),
    );

    final currenciesRes = await _getCurrencies.call();
    List<CurrencyEntity> currencies = [];
    String? currencyError;
    currenciesRes.fold(
      (failure) => currencyError = failure.message,
      (list) => currencies = list,
    );

    if (currencyError != null) {
      emit(
        state.copyWith(
          status: JournalEntryFormStatus.failure,
          errorMessage: currencyError,
          currencies: currencies,
          currencySelected: currencies.isNotEmpty ? currencies.first : null,
          isLoadingCurrencies: false,
        ),
      );
      return;
    }

    CurrencyEntity? selectedCurrency;
    if (currencies.isNotEmpty) {
      selectedCurrency = event.editingEntry != null
          ? currencies.firstWhere(
              (currency) => currency.id == event.editingEntry!.currencyId,
              orElse: () => currencies.first,
            )
          : currencies.first;
    }

    if (event.editingEntry != null) {
      final itemsRes = await _getJournalItemsByEntryId(event.editingEntry!.id);
      final subAccsRes = await _getSubAccounts();

      itemsRes.fold(
        (failure) => emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (items) {
          final drafts = items.map((item) {
            SubAccountEntity? subAccount;
            subAccsRes.fold((_) {}, (accs) {
              final match = accs.where((a) => a.id == item.accountId);
              if (match.isNotEmpty) subAccount = match.first;
            });

            final isDebtorAccount =
                subAccount
                    ?.subAccountType
                    .mainAccountType
                    .accountStatus
                    .isDebtor ??
                true;
            final isDebtorSide = isDebtorAccount
                ? item.journalStatus == JournalStatus.increment
                : item.journalStatus == JournalStatus.decrement;

            return JournalItemDraft(
              account: subAccount,
              amount: item.amount,
              side: isDebtorSide
                  ? AccountStatus.debtor
                  : AccountStatus.creditor,
              lineDescription: item.lineDescription ?? '',
            );
          }).toList();

          emit(
            JournalEntryFormState(
              status: JournalEntryFormStatus.initial,
              editingEntry: event.editingEntry,
              description: event.editingEntry!.description ?? '',
              date: event.editingEntry!.createdAt,
              currencySelected: selectedCurrency,
              currencies: currencies,
              isLoadingCurrencies: false,
              items: drafts,
            ),
          );
        },
      );
    } else {
      emit(
        JournalEntryFormState.initial().copyWith(
          currencies: currencies,
          currencySelected: selectedCurrency,
          isLoadingCurrencies: false,
        ),
      );
    }
  }

  void _onJournalEntryDescriptionChanged(
    JournalEntryDescriptionChanged event,
    Emitter<JournalEntryFormState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onJournalEntryDateChanged(
    JournalEntryDateChanged event,
    Emitter<JournalEntryFormState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  void _onJournalEntryCurrencyChanged(
    JournalEntryCurrencyChanged event,
    Emitter<JournalEntryFormState> emit,
  ) {
    emit(
      state.copyWith(currencySelected: event.currency, exPrice: event.exPrice),
    );
  }

  void _onAddJournalItemField(
    AddJournalItemField event,
    Emitter<JournalEntryFormState> emit,
  ) {
    final newList = List<JournalItemDraft>.from(state.items)
      ..add(JournalItemDraft(side: event.side));
    emit(state.copyWith(items: newList));
  }

  void _onRemoveJournalItemField(
    RemoveJournalItemField event,
    Emitter<JournalEntryFormState> emit,
  ) {
    // Ensure at least one item remains for the side
    final sideCount = state.items.where((it) => it.side == event.side).length;
    if (sideCount <= 1) {
      emit(
        state.copyWith(
          errorMessage:
              'يجب أن يحتوي كل قسم (مدين/دائن) على بند واحد على الأقل.',
        ),
      );
      return;
    }

    // Map side-specific index to global index
    int globalIndex = -1;
    var seen = 0;
    for (var i = 0; i < state.items.length; i++) {
      if (state.items[i].side == event.side) {
        if (seen == event.index) {
          globalIndex = i;
          break;
        }
        seen++;
      }
    }
    if (globalIndex < 0) return;

    final newList = List<JournalItemDraft>.from(state.items)
      ..removeAt(globalIndex);
    emit(state.copyWith(items: newList));
  }

  Future<void> _onJournalItemFieldChanged(
    JournalItemFieldChanged event,
    Emitter<JournalEntryFormState> emit,
  ) async {
    final newList = List<JournalItemDraft>.from(state.items);

    // Map side-specific index to global index
    int globalIndex = -1;
    var seen = 0;
    for (var i = 0; i < newList.length; i++) {
      if (newList[i].side == event.side) {
        if (seen == event.index) {
          globalIndex = i;
          break;
        }
        seen++;
      }
    }
    if (globalIndex < 0) return;

    final target = newList[globalIndex];

    SubAccountEntity? updatedAccount = target.account;
    if (event.accountId != null) {
      final res = await _getSubAccountById(event.accountId!);
      res.fold((_) {}, (acc) => updatedAccount = acc);
    } else if (event.accountId == null &&
        event.accountName == null &&
        target.account != null &&
        event.amount == null) {
      updatedAccount = null;
    }

    final updatedAmount = event.amount ?? target.amount;

    newList[globalIndex] = target.copyWith(
      side: event.side,
      account: updatedAccount,
      amount: updatedAmount,
      lineDescription: event.lineDescription ?? target.lineDescription,
      clearAccount:
          event.accountId == null &&
          event.accountName == null &&
          target.account != null &&
          event.amount == null,
    );

    // Check if user entered any amounts to avoid showing unbalanced message on empty form.
    final anyAmountEntered = newList.any((it) => it.amount != 0.0);
    final totalDebit = newList
        .where((it) => it.side.isDebtor)
        .fold<double>(0.0, (s, it) => s + it.amount);
    final totalCredit = newList
        .where((it) => it.side.isCreditor)
        .fold<double>(0.0, (s, it) => s + it.amount);

    String? errorMessage;
    if (anyAmountEntered && (totalDebit - totalCredit).abs() > 0.001) {
      errorMessage = 'القيد غير متزن';
    } else {
      errorMessage = null;
    }

    emit(state.copyWith(items: newList, errorMessage: errorMessage));
  }

  Future<void> _onSubmitJournalEntryForm(
    SubmitJournalEntryForm event,
    Emitter<JournalEntryFormState> emit,
  ) async {
    // Validations
    if (!state.isBalanced) {
      emit(
        state.copyWith(errorMessage: 'القيد غير متزن! الفرق يجب أن يكون صفر.'),
      );
      return;
    }
    // Ensure at least one item per side
    final hasDebit = state.items.any((it) => it.side.isDebtor);
    final hasCredit = state.items.any((it) => it.side.isCreditor);
    if (!hasDebit || !hasCredit) {
      emit(
        state.copyWith(
          errorMessage:
              'يجب أن يحتوي القيد على بند واحد على الأقل في كل من المدين والدائن.',
        ),
      );
      return;
    }
    if (state.items.any((item) => item.account == null)) {
      emit(state.copyWith(errorMessage: 'يرجى تحديد الحسابات لجميع البنود.'));
      return;
    }
    if (state.items.any((item) => item.amount == 0)) {
      emit(state.copyWith(errorMessage: 'جميع البنود يجب أن تحتوي على مبالغ.'));
      return;
    }

    emit(state.copyWith(status: JournalEntryFormStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    final String reference = 'JE-${DateTime.now().millisecondsSinceEpoch}';

    // Insert Entry
    final entry = JournalEntryEntity(
      id: state.editingEntry?.id ?? 0,
      referenceNumber: state.editingEntry?.referenceNumber ?? reference,
      description: state.description,
      createdAt: state.date,
      createdBy: 1, // Default user
      currencyId: state.currencySelected!.id,
      baseAmount: state.totalDebit,
    );

    final items = <JournalItemEntity>[];
    for (final itemDraft in state.items) {
      final subAccountResult = await _getSubAccountById(itemDraft.account!.id);
      final subAccount = subAccountResult.fold((failure) {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      }, (account) => account);
      if (subAccount == null) return;

      final subAccountCurrencyId = subAccount.currencyId;
      final exPriceResult = await _getExPrice(
        state.currencySelected!.id,
        subAccountCurrencyId,
      );
      final exPrice = exPriceResult.fold((failure) {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      }, (rate) => rate);
      if (exPrice == null) return;

      final mainAccountResult = await _getMainAccountById(
        subAccount.mainAccountId,
      );
      final mainAccount = mainAccountResult.fold((failure) {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      }, (account) => account);
      if (mainAccount == null) return;
      if (mainAccount.currencyId == null) {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: 'لا يمكن تحديد عملة الحساب الرئيسي للبند.',
          ),
        );
        return;
      }

      final exPriceMainResult = await _getExPrice(
        state.currencySelected!.id,
        mainAccount.currencyId!,
      );
      final exPriceMain = exPriceMainResult.fold((failure) {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      }, (rate) => rate);
      if (exPriceMain == null) return;

      items.add(
        JournalItemEntity(
          id: 0,
          entryId: state.editingEntry?.id ?? 0,
          accountId: itemDraft.account!.id,
          amount: itemDraft.amount,
          lineDescription: itemDraft.lineDescription.isNotEmpty
              ? itemDraft.lineDescription
              : state.description,
          currencyId: state.currencySelected!.id,
          exPrice: exPrice,
          expriceMain: exPriceMain,
          journalStatus: itemDraft.journalStatus!,
        ),
      );
    }

    final entryResult = await _insertJournalEntryWithItems(
      entry.copyWith(items: items),
    );

    await entryResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: JournalEntryFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (savedEntry) async {
        emit(
          state.copyWith(
            status: JournalEntryFormStatus.success,
            editingEntry: savedEntry,
          ),
        );
      },
    );
  }
}
