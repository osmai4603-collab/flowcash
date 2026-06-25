import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_item_repository_usecases.dart';
import 'account_statement_event.dart';
import 'account_statement_state.dart';

class AccountStatementBloc
    extends Bloc<AccountStatementEvent, AccountStatementState> {
  final GetSubAccountByIdUseCase _getSubAccountById;
  final GetJournalItemsByAccountIdUseCase _getJournalItemsByAccountId;
  final GetJournalEntriesUseCase _getJournalEntries;

  AccountStatementBloc({
    required GetSubAccountByIdUseCase getSubAccountById,
    required GetJournalItemsByAccountIdUseCase getJournalItemsByAccountId,
    required GetJournalEntriesUseCase getJournalEntries,
  }) : _getSubAccountById = getSubAccountById,
       _getJournalItemsByAccountId = getJournalItemsByAccountId,
       _getJournalEntries = getJournalEntries,
       super(AccountStatementState.initial()) {
    on<LoadAccountStatement>(_onLoadAccountStatement);
  }

  Future<void> _onLoadAccountStatement(
    LoadAccountStatement event,
    Emitter<AccountStatementState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AccountStatementStatus.loading,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    // 1. Fetch sub-account details
    final accountResult = await _getSubAccountById(event.subAccountId);
    final subAccount = accountResult.fold((failure) => null, (acc) => acc);

    if (subAccount == null) {
      emit(
        state.copyWith(
          status: AccountStatementStatus.failure,
          errorMessage: 'الحساب الفرعي غير موجود',
        ),
      );
      return;
    }

    // 2. Fetch all journal items for this account
    final itemsResult = await _getJournalItemsByAccountId(event.subAccountId);
    await itemsResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: AccountStatementStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (allItems) async {
        if (allItems.isEmpty) {
          emit(
            state.copyWith(
              status: AccountStatementStatus.success,
              subAccount: subAccount,
              items: [],
              entries: {},
              openingBalance: 0.0,
            ),
          );
          return;
        }

        // 3. Extract entry IDs to fetch corresponding journal entries
        final entryIds = allItems.map((item) => item.entryId).toSet();
        final entriesResult = await _getJournalEntries(ids: entryIds);

        entriesResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: AccountStatementStatus.failure,
                errorMessage: failure.message,
              ),
            );
          },
          (entriesList) {
            final entriesMap = {for (var entry in entriesList) entry.id: entry};

            double openingBalance = 0.0;
            final filteredItems = <dynamic>[];

            for (final item in allItems) {
              final entry = entriesMap[item.entryId];
              if (entry == null) continue;

              final entryDate = entry.createdAt;

              // If startDate is set and entry is before it, add to opening balance
              if (event.startDate != null &&
                  entryDate.isBefore(event.startDate!)) {
                openingBalance += item.historyAmount;
              } else if (event.endDate != null &&
                  entryDate.isAfter(event.endDate!)) {
                // Ignore transactions after the end date
                continue;
              } else {
                filteredItems.add(item);
              }
            }

            // Sort filtered items by entry date ascending
            filteredItems.sort((a, b) {
              final entryA = entriesMap[a.id];
              final entryB = entriesMap[b.id];
              if (entryA == null || entryB == null) return 0;
              return entryA.createdAt.compareTo(entryB.createdAt);
            });

            emit(
              state.copyWith(
                status: AccountStatementStatus.success,
                subAccount: subAccount,
                items: List.from(filteredItems),
                entries: entriesMap,
                openingBalance: openingBalance,
              ),
            );
          },
        );
      },
    );
  }
}
