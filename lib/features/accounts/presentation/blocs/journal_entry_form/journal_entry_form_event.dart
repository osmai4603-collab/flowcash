import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'journal_entry_form_state.dart';

sealed class JournalEntryFormEvent extends Equatable {
  const JournalEntryFormEvent();

  @override
  List<Object?> get props => [];
}

class InitJournalEntryForm extends JournalEntryFormEvent {
  final JournalEntryEntity? editingEntry;
  const InitJournalEntryForm({this.editingEntry});

  @override
  List<Object?> get props => [editingEntry];
}

class JournalEntryDescriptionChanged extends JournalEntryFormEvent {
  final String description;
  const JournalEntryDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class JournalEntryDateChanged extends JournalEntryFormEvent {
  final DateTime date;
  const JournalEntryDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class JournalEntryCurrencyChanged extends JournalEntryFormEvent {
  final CurrencyEntity currency;
  final double exPrice;
  const JournalEntryCurrencyChanged(this.currency, this.exPrice);

  @override
  List<Object?> get props => [currency, exPrice];
}

class AddJournalItemField extends JournalEntryFormEvent {
  final JournalItemSide side;
  const AddJournalItemField(this.side);

  @override
  List<Object?> get props => [side];
}

class RemoveJournalItemField extends JournalEntryFormEvent {
  // index is the position inside the side-specific list (e.g., 0 for first debit item)
  final JournalItemSide side;
  final int index;
  const RemoveJournalItemField(this.side, this.index);

  @override
  List<Object?> get props => [side, index];
}

class JournalItemFieldChanged extends JournalEntryFormEvent {
  final JournalItemSide side;
  final int index; // index within side-specific list
  final int? accountId;
  final String? accountName;
  final double? debit;
  final double? credit;
  final String? lineDescription;

  const JournalItemFieldChanged({
    required this.side,
    required this.index,
    this.accountId,
    this.accountName,
    this.debit,
    this.credit,
    this.lineDescription,
  });

  @override
  List<Object?> get props => [
    side,
    index,
    accountId,
    accountName,
    debit,
    credit,
    lineDescription,
  ];
}

class SubmitJournalEntryForm extends JournalEntryFormEvent {
  const SubmitJournalEntryForm();
}
