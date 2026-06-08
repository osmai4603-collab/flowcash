import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_item_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'group_balances_event.dart';
import 'group_balances_state.dart';

class GroupBalancesBloc extends Bloc<GroupBalancesEvent, GroupBalancesState> {
  final GetMainAccountsUseCase _getMainAccounts;
  final GetSubAccountsUseCase _getSubAccounts;
  final GetJournalItemsUseCase _getJournalItems;
  final GetJournalEntriesUseCase _getJournalEntries;

  GroupBalancesBloc({
    required GetMainAccountsUseCase getMainAccounts,
    required GetSubAccountsUseCase getSubAccounts,
    required GetJournalItemsUseCase getJournalItems,
    required GetJournalEntriesUseCase getJournalEntries,
  }) : _getMainAccounts = getMainAccounts,
       _getSubAccounts = getSubAccounts,
       _getJournalItems = getJournalItems,
       _getJournalEntries = getJournalEntries,
       super(GroupBalancesState.initial()) {
    on<LoadGroupBalances>(_onLoadGroupBalances);
  }

  Future<void> _onLoadGroupBalances(
    LoadGroupBalances event,
    Emitter<GroupBalancesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GroupBalancesStatus.loading,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    final mainResult = await _getMainAccounts();
    final subResult = await _getSubAccounts();

    await mainResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: GroupBalancesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (mainAccounts) async {
        await subResult.fold(
          (failure) async => emit(
            state.copyWith(
              status: GroupBalancesStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (subAccounts) async {
            if (event.startDate == null && event.endDate == null) {
              final balances = <int, Map<String, double>>{};
              for (final sub in subAccounts) {
                balances[sub.id] = {
                  'debit': sub.debitBalance,
                  'credit': sub.creditBalance,
                };
              }
              emit(
                state.copyWith(
                  status: GroupBalancesStatus.success,
                  mainAccounts: mainAccounts,
                  subAccounts: subAccounts,
                  subaccountBalances: balances,
                ),
              );
            } else {
              final itemsResult = await _getJournalItems();
              final entriesResult = await _getJournalEntries();

              itemsResult.fold(
                (failure) => emit(
                  state.copyWith(
                    status: GroupBalancesStatus.failure,
                    errorMessage: failure.message,
                  ),
                ),
                (allItems) {
                  entriesResult.fold(
                    (failure) => emit(
                      state.copyWith(
                        status: GroupBalancesStatus.failure,
                        errorMessage: failure.message,
                      ),
                    ),
                    (allEntries) {
                      final entriesMap = {
                        for (var entry in allEntries) entry.id: entry,
                      };
                      final balances = <int, Map<String, double>>{};

                      for (final sub in subAccounts) {
                        balances[sub.id] = {'debit': 0.0, 'credit': 0.0};
                      }

                      for (final item in allItems) {
                        final entry = entriesMap[item.entryId];
                        if (entry == null) continue;

                        final date = entry.createdAt;
                        if (event.startDate != null &&
                            date.isBefore(event.startDate!))
                          continue;
                        if (event.endDate != null &&
                            date.isAfter(event.endDate!))
                          continue;

                        final current =
                            balances[item.accountId] ??
                            {'debit': 0.0, 'credit': 0.0};
                        balances[item.accountId] = {
                          'debit': current['debit']! + item.debit,
                          'credit': current['credit']! + item.credit,
                        };
                      }

                      emit(
                        state.copyWith(
                          status: GroupBalancesStatus.success,
                          mainAccounts: mainAccounts,
                          subAccounts: subAccounts,
                          subaccountBalances: balances,
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
