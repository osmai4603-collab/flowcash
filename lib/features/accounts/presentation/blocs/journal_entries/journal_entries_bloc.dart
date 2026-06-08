import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_item_repository_usecases.dart';
import 'journal_entries_event.dart';
import 'journal_entries_state.dart';

class JournalEntriesBloc
    extends Bloc<JournalEntriesEvent, JournalEntriesState> {
  final GetJournalEntriesUseCase _getJournalEntries;
  final DeleteJournalEntryUseCase _deleteJournalEntry;
  final GetJournalItemsByEntryIdUseCase _getJournalItemsByEntryId;

  JournalEntriesBloc({
    required GetJournalEntriesUseCase getJournalEntries,
    required DeleteJournalEntryUseCase deleteJournalEntry,
    required GetJournalItemsByEntryIdUseCase getJournalItemsByEntryId,
  }) : _getJournalEntries = getJournalEntries,
       _deleteJournalEntry = deleteJournalEntry,
       _getJournalItemsByEntryId = getJournalItemsByEntryId,
       super(JournalEntriesState.initial()) {
    on<LoadJournalEntries>(_onLoadJournalEntries);
    on<SelectJournalEntry>(_onSelectJournalEntry);
    on<DeleteJournalEntry>(_onDeleteJournalEntry);
  }

  Future<void> _onLoadJournalEntries(
    LoadJournalEntries event,
    Emitter<JournalEntriesState> emit,
  ) async {
    emit(state.copyWith(status: JournalEntriesStatus.loading));
    final result = await _getJournalEntries();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: JournalEntriesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (entries) => emit(
        state.copyWith(
          status: JournalEntriesStatus.success,
          entries: entries,
          clearSelectedEntry: true,
          selectedEntryItems: [],
        ),
      ),
    );
  }

  Future<void> _onSelectJournalEntry(
    SelectJournalEntry event,
    Emitter<JournalEntriesState> emit,
  ) async {
    // Set the selected entry immediately and clear items while deciding
    // whether to reuse already-loaded items or fetch them from the repository.
    emit(state.copyWith(selectedEntry: event.entry, selectedEntryItems: []));

    // If the tapped entry already contains its items, use them directly
    // to avoid an unnecessary load. Otherwise fetch items by entry id.
    if (event.entry.items.isNotEmpty) {
      emit(state.copyWith(selectedEntryItems: event.entry.items));
      return;
    }

    final result = await _getJournalItemsByEntryId(event.entry.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (items) => emit(state.copyWith(selectedEntryItems: items)),
    );
  }

  Future<void> _onDeleteJournalEntry(
    DeleteJournalEntry event,
    Emitter<JournalEntriesState> emit,
  ) async {
    final result = await _deleteJournalEntry(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => add(const LoadJournalEntries()),
    );
  }
}
