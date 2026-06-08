import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'chart_of_accounts_event.dart';
import 'chart_of_accounts_state.dart';

class ChartOfAccountsBloc
    extends Bloc<ChartOfAccountsEvent, ChartOfAccountsState> {
  final GetMainAccountsUseCase _getMainAccounts;
  final GetSubAccountsUseCase _getSubAccounts;
  final DeleteMainAccountUseCase _deleteMainAccount;
  final DeleteSubAccountUseCase _deleteSubAccount;

  ChartOfAccountsBloc({
    required GetMainAccountsUseCase getMainAccounts,
    required GetSubAccountsUseCase getSubAccounts,
    required DeleteMainAccountUseCase deleteMainAccount,
    required DeleteSubAccountUseCase deleteSubAccount,
  }) : _getMainAccounts = getMainAccounts,
       _getSubAccounts = getSubAccounts,
       _deleteMainAccount = deleteMainAccount,
       _deleteSubAccount = deleteSubAccount,
       super(ChartOfAccountsState.initial()) {
    on<LoadChartOfAccounts>(_onLoadChartOfAccounts);
    on<FilterChartOfAccounts>(_onFilterChartOfAccounts);
    on<DeleteMainAccount>(_onDeleteMainAccount);
    on<DeleteSubAccount>(_onDeleteSubAccount);
  }

  Future<void> _onLoadChartOfAccounts(
    LoadChartOfAccounts event,
    Emitter<ChartOfAccountsState> emit,
  ) async {
    emit(state.copyWith(status: ChartOfAccountsStatus.loading));

    final mainResult = await _getMainAccounts();
    final subResult = await _getSubAccounts();

    mainResult.fold(
      (failure) => emit(
        state.copyWith(
          status: ChartOfAccountsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (mainAccs) {
        subResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ChartOfAccountsStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (subAccs) => emit(
            state.copyWith(
              status: ChartOfAccountsStatus.success,
              mainAccounts: mainAccs,
              subAccounts: subAccs,
            ),
          ),
        );
      },
    );
  }

  void _onFilterChartOfAccounts(
    FilterChartOfAccounts event,
    Emitter<ChartOfAccountsState> emit,
  ) {
    if (event.group == null) {
      emit(state.copyWith(clearGroup: true));
    } else {
      emit(state.copyWith(selectedGroup: event.group));
    }
  }

  Future<void> _onDeleteMainAccount(
    DeleteMainAccount event,
    Emitter<ChartOfAccountsState> emit,
  ) async {
    final result = await _deleteMainAccount(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => add(const LoadChartOfAccounts()),
    );
  }

  Future<void> _onDeleteSubAccount(
    DeleteSubAccount event,
    Emitter<ChartOfAccountsState> emit,
  ) async {
    final result = await _deleteSubAccount(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => add(const LoadChartOfAccounts()),
    );
  }
}
