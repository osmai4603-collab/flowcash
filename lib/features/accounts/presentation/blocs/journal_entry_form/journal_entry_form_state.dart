import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

import '../../../../../core/enums/account_status_enum.dart';

enum JournalEntryFormStatus { initial, loading, success, failure }

class JournalItemDraft extends Equatable {
  final SubAccountEntity? account;
  final AccountStatus side;
  final double amount;
  final String lineDescription;
  JournalStatus? get journalStatus {
    if (account == null) {
      return null;
    }
    return account!.subAccountType.mainAccountType.accountStatus.name ==
            side.name
        ? JournalStatus.increment
        : JournalStatus.decrement;
  }

  const JournalItemDraft({
    required this.side,
    this.account,
    this.amount = 0.0,
    this.lineDescription = '',
  });

  JournalItemDraft copyWith({
    AccountStatus? side,
    SubAccountEntity? account,
    double? amount,
    String? lineDescription,
    bool clearAccount = false,
  }) {
    return JournalItemDraft(
      side: side ?? this.side,
      account: clearAccount ? null : (account ?? this.account),
      amount: amount ?? this.amount,
      lineDescription: lineDescription ?? this.lineDescription,
    );
  }

  @override
  List<Object?> get props => [account, side, amount, lineDescription];
}

class JournalEntryFormState extends Equatable {
  final JournalEntryFormStatus status;
  final JournalEntryEntity? editingEntry;
  final String description;
  final DateTime date;
  final CurrencyEntity? currencySelected;
  final List<CurrencyEntity> currencies;
  final bool isLoadingCurrencies;
  final List<JournalItemDraft> items;
  final String? errorMessage;

  const JournalEntryFormState({
    required this.status,
    this.editingEntry,
    required this.description,
    required this.date,
    required this.currencySelected,
    required this.currencies,
    required this.isLoadingCurrencies,
    required this.items,
    this.errorMessage,
  });

  factory JournalEntryFormState.initial() {
    return JournalEntryFormState(
      status: JournalEntryFormStatus.initial,
      description: '',
      date: DateTime.now(),
      currencySelected: null,
      currencies: const [],
      isLoadingCurrencies: false,
      items: const [
        JournalItemDraft(side: AccountStatus.debtor),
        JournalItemDraft(side: AccountStatus.creditor),
      ], // Default to 2 empty rows: one debit and one credit
    );
  }

  JournalEntryFormState copyWith({
    JournalEntryFormStatus? status,
    JournalEntryEntity? editingEntry,
    String? description,
    DateTime? date,
    CurrencyEntity? currencySelected,
    List<CurrencyEntity>? currencies,
    bool? isLoadingCurrencies,
    double? exPrice,
    List<JournalItemDraft>? items,
    String? errorMessage,
  }) {
    return JournalEntryFormState(
      status: status ?? this.status,
      editingEntry: editingEntry ?? this.editingEntry,
      description: description ?? this.description,
      date: date ?? this.date,
      currencySelected: currencySelected ?? this.currencySelected,
      currencies: currencies ?? this.currencies,
      isLoadingCurrencies: isLoadingCurrencies ?? this.isLoadingCurrencies,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalDebit => items
      .where((item) => item.side.isDebtor)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalCredit => items
      .where((item) => item.side.isCreditor)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get difference => totalDebit - totalCredit;
  bool get isBalanced => totalCredit == totalDebit; // difference.abs() < 0.001;

  @override
  List<Object?> get props => [
    status,
    editingEntry,
    description,
    date,
    currencySelected,
    currencies,
    isLoadingCurrencies,
    items,
    errorMessage,
  ];
}
