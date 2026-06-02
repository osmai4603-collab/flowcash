import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';

sealed class JournalEntriesEvent extends Equatable {
  const JournalEntriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadJournalEntries extends JournalEntriesEvent {
  const LoadJournalEntries();
}

class SelectJournalEntry extends JournalEntriesEvent {
  final JournalEntryEntity entry;
  const SelectJournalEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteJournalEntry extends JournalEntriesEvent {
  final int id;
  const DeleteJournalEntry(this.id);

  @override
  List<Object?> get props => [id];
}
