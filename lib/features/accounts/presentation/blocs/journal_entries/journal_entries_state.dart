import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

enum JournalEntriesStatus { initial, loading, success, failure }

class JournalEntriesState extends Equatable {
  final JournalEntriesStatus status;
  final List<JournalEntryEntity> entries;
  final JournalEntryEntity? selectedEntry;
  final List<JournalItemEntity> selectedEntryItems;
  final String? errorMessage;

  const JournalEntriesState({
    required this.status,
    required this.entries,
    this.selectedEntry,
    required this.selectedEntryItems,
    this.errorMessage,
  });

  factory JournalEntriesState.initial() {
    return const JournalEntriesState(
      status: JournalEntriesStatus.initial,
      entries: [],
      selectedEntryItems: [],
    );
  }

  JournalEntriesState copyWith({
    JournalEntriesStatus? status,
    List<JournalEntryEntity>? entries,
    JournalEntryEntity? selectedEntry,
    bool clearSelectedEntry = false,
    List<JournalItemEntity>? selectedEntryItems,
    String? errorMessage,
  }) {
    return JournalEntriesState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      selectedEntry: clearSelectedEntry
          ? null
          : (selectedEntry ?? this.selectedEntry),
      selectedEntryItems: selectedEntryItems ?? this.selectedEntryItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    selectedEntry,
    selectedEntryItems,
    errorMessage,
  ];
}
