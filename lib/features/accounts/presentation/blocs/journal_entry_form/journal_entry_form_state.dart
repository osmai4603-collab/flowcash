import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';

enum JournalItemSide { debit, credit }

enum JournalEntryFormStatus { initial, loading, success, failure }

class JournalItemDraft extends Equatable {
  final int? accountId;
  final String? accountName;
  final double debit;
  final double credit;
  final JournalItemSide side;
  final String lineDescription;

  const JournalItemDraft({
    this.accountId,
    this.accountName,
    this.debit = 0.0,
    this.credit = 0.0,
    this.side = JournalItemSide.debit,
    this.lineDescription = '',
  });

  JournalItemDraft copyWith({
    int? accountId,
    String? accountName,
    double? debit,
    double? credit,
    String? lineDescription,
    JournalItemSide? side,
    bool clearAccount = false,
  }) {
    return JournalItemDraft(
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      accountName: clearAccount ? null : (accountName ?? this.accountName),
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      side: side ?? this.side,
      lineDescription: lineDescription ?? this.lineDescription,
    );
  }

  @override
  List<Object?> get props => [accountId, accountName, debit, credit, side, lineDescription];
}

class JournalEntryFormState extends Equatable {
  final JournalEntryFormStatus status;
  final JournalEntryEntity? editingEntry;
  final String description;
  final DateTime date;
  final String currencyId;
  final double exPrice;
  final List<JournalItemDraft> items;
  final String? errorMessage;

  const JournalEntryFormState({
    required this.status,
    this.editingEntry,
    required this.description,
    required this.date,
    required this.currencyId,
    required this.exPrice,
    required this.items,
    this.errorMessage,
  });

  factory JournalEntryFormState.initial() {
    return JournalEntryFormState(
      status: JournalEntryFormStatus.initial,
      description: '',
      date: DateTime.now(),
      currencyId: '1',
      exPrice: 1.0,
      items: const [
        JournalItemDraft(side: JournalItemSide.debit),
        JournalItemDraft(side: JournalItemSide.credit),
      ], // Default to 2 empty rows: one debit and one credit
    );
  }

  JournalEntryFormState copyWith({
    JournalEntryFormStatus? status,
    JournalEntryEntity? editingEntry,
    String? description,
    DateTime? date,
    String? currencyId,
    double? exPrice,
    List<JournalItemDraft>? items,
    String? errorMessage,
  }) {
    return JournalEntryFormState(
      status: status ?? this.status,
      editingEntry: editingEntry ?? this.editingEntry,
      description: description ?? this.description,
      date: date ?? this.date,
      currencyId: currencyId ?? this.currencyId,
      exPrice: exPrice ?? this.exPrice,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalDebit => items.fold(0.0, (sum, item) => sum + item.debit);
  double get totalCredit => items.fold(0.0, (sum, item) => sum + item.credit);
  double get difference => totalDebit - totalCredit;
  bool get isBalanced => difference.abs() < 0.001;

  @override
  List<Object?> get props => [
        status,
        editingEntry,
        description,
        date,
        currencyId,
        exPrice,
        items,
        errorMessage,
      ];
}
