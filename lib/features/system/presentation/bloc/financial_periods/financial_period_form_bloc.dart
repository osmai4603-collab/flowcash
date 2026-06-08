import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:fpdart/fpdart.dart';

abstract class FinancialPeriodFormEvent extends Equatable {
  const FinancialPeriodFormEvent();

  @override
  List<Object?> get props => [];
}

class FinancialPeriodFormNameChanged extends FinancialPeriodFormEvent {
  final String value;

  const FinancialPeriodFormNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormStartDateChanged extends FinancialPeriodFormEvent {
  final DateTime value;

  const FinancialPeriodFormStartDateChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormEndDateChanged extends FinancialPeriodFormEvent {
  final DateTime? value;

  const FinancialPeriodFormEndDateChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormLastPeriodIdChanged extends FinancialPeriodFormEvent {
  final String value;

  const FinancialPeriodFormLastPeriodIdChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormCurrencyChanged extends FinancialPeriodFormEvent {
  final String value;

  const FinancialPeriodFormCurrencyChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormBalanceChanged extends FinancialPeriodFormEvent {
  final String value;

  const FinancialPeriodFormBalanceChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class _LoadCurrenciesEvent extends FinancialPeriodFormEvent {}

class _LoadPeriodsEvent extends FinancialPeriodFormEvent {}

class FinancialPeriodFormInventoryTypeChanged extends FinancialPeriodFormEvent {
  final AccountingInventoryType value;

  const FinancialPeriodFormInventoryTypeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FinancialPeriodFormSubmitted extends FinancialPeriodFormEvent {
  const FinancialPeriodFormSubmitted();
}

class FinancialPeriodFormState extends Equatable {
  final String periodName;
  final DateTime dateOfStartPeriod;
  final DateTime? dateOfEndPeriod;
  final String lastPeriodId;
  final String currencyId;
  final String balance;
  final AccountingInventoryType inventoryType;
  final List<CurrencyEntity> currencies;
  final bool isLoadingCurrencies;
  final List<AccountingPeriodEntity> periods;
  final bool isLoadingPeriods;
  final bool isSubmitting;
  final bool isSuccess;
  final AccountingPeriodEntity? savedEntity;
  final String? errorMessage;

  const FinancialPeriodFormState({
    required this.periodName,
    required this.dateOfStartPeriod,
    this.dateOfEndPeriod,
    this.lastPeriodId = '',
    required this.currencyId,
    required this.balance,
    required this.inventoryType,
    this.currencies = const [],
    this.isLoadingCurrencies = false,
    this.periods = const [],
    this.isLoadingPeriods = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.savedEntity,
    this.errorMessage,
  });

  factory FinancialPeriodFormState.initial(
    AccountingPeriodEntity? initialValue,
  ) {
    return FinancialPeriodFormState(
      periodName: initialValue?.periodName ?? '',
      dateOfStartPeriod: initialValue?.dateOfStartPeriod ?? DateTime.now(),
      dateOfEndPeriod: initialValue?.dateOfEndPeriod,
      lastPeriodId: initialValue?.lastPeriodId?.toString() ?? '',
      currencyId: initialValue?.currencyId ?? '',
      balance: initialValue?.balance.toStringAsFixed(2) ?? '0.00',
      currencies: const [],
      isLoadingCurrencies: false,
      periods: const [],
      isLoadingPeriods: false,
      inventoryType:
          initialValue?.inventoryType ?? AccountingInventoryType.periodic,
    );
  }

  FinancialPeriodFormState copyWith({
    String? periodName,
    DateTime? dateOfStartPeriod,
    DateTime? dateOfEndPeriod,
    String? lastPeriodId,
    String? currencyId,
    String? balance,
    List<CurrencyEntity>? currencies,
    bool? isLoadingCurrencies,
    List<AccountingPeriodEntity>? periods,
    bool? isLoadingPeriods,
    AccountingInventoryType? inventoryType,
    bool? isSubmitting,
    bool? isSuccess,
    AccountingPeriodEntity? savedEntity,
    String? errorMessage,
  }) {
    return FinancialPeriodFormState(
      periodName: periodName ?? this.periodName,
      dateOfStartPeriod: dateOfStartPeriod ?? this.dateOfStartPeriod,
      dateOfEndPeriod: dateOfEndPeriod ?? this.dateOfEndPeriod,
      lastPeriodId: lastPeriodId ?? this.lastPeriodId,
      currencyId: currencyId ?? this.currencyId,
      balance: balance ?? this.balance,
      currencies: currencies ?? this.currencies,
      isLoadingCurrencies: isLoadingCurrencies ?? this.isLoadingCurrencies,
      periods: periods ?? this.periods,
      isLoadingPeriods: isLoadingPeriods ?? this.isLoadingPeriods,
      inventoryType: inventoryType ?? this.inventoryType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      savedEntity: savedEntity ?? this.savedEntity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    periodName,
    dateOfStartPeriod,
    dateOfEndPeriod,
    lastPeriodId,
    currencyId,
    balance,
    currencies,
    isLoadingCurrencies,
    periods,
    isLoadingPeriods,
    inventoryType,
    isSubmitting,
    isSuccess,
    savedEntity,
    errorMessage,
  ];
}

class FinancialPeriodFormBloc
    extends Bloc<FinancialPeriodFormEvent, FinancialPeriodFormState> {
  final InsertAccountingPeriodUseCase _insertAccountingPeriodUseCase;
  final UpdateAccountingPeriodUseCase _updateAccountingPeriodUseCase;
  final GetCurrenciesUseCase _getCurrenciesUseCase;
  final GetAccountingPeriodsUseCase _getAccountingPeriodsUseCase;
  final AccountingPeriodEntity? initialValue;

  FinancialPeriodFormBloc({
    required this.initialValue,
    required InsertAccountingPeriodUseCase insertAccountingPeriodUseCase,
    required UpdateAccountingPeriodUseCase updateAccountingPeriodUseCase,
    required GetCurrenciesUseCase getCurrenciesUseCase,
    required GetAccountingPeriodsUseCase getAccountingPeriodsUseCase,
  }) : _insertAccountingPeriodUseCase = insertAccountingPeriodUseCase,
       _updateAccountingPeriodUseCase = updateAccountingPeriodUseCase,
       _getCurrenciesUseCase = getCurrenciesUseCase,
       _getAccountingPeriodsUseCase = getAccountingPeriodsUseCase,
       super(FinancialPeriodFormState.initial(initialValue)) {
    on<FinancialPeriodFormNameChanged>(_onNameChanged);
    on<FinancialPeriodFormStartDateChanged>(_onStartDateChanged);
    on<FinancialPeriodFormEndDateChanged>(_onEndDateChanged);
    on<FinancialPeriodFormLastPeriodIdChanged>(_onLastPeriodIdChanged);
    on<FinancialPeriodFormCurrencyChanged>(_onCurrencyChanged);
    on<FinancialPeriodFormBalanceChanged>(_onBalanceChanged);
    on<FinancialPeriodFormInventoryTypeChanged>(_onInventoryTypeChanged);
    on<FinancialPeriodFormSubmitted>(_onSubmitted);
    on<_LoadCurrenciesEvent>(_onLoadCurrencies);
    on<_LoadPeriodsEvent>(_onLoadPeriods);

    // trigger initial loads
    add(_LoadCurrenciesEvent());
    add(_LoadPeriodsEvent());
  }

  Future<void> _onLoadCurrencies(
    _LoadCurrenciesEvent event,
    Emitter<FinancialPeriodFormState> emit,
  ) async {
    emit(state.copyWith(isLoadingCurrencies: true));
    final res = await _getCurrenciesUseCase.call();
    res.fold(
      (failure) => emit(state.copyWith(isLoadingCurrencies: false)),
      (currencies) => emit(
        state.copyWith(currencies: currencies, isLoadingCurrencies: false),
      ),
    );
  }

  Future<void> _onLoadPeriods(
    _LoadPeriodsEvent event,
    Emitter<FinancialPeriodFormState> emit,
  ) async {
    emit(state.copyWith(isLoadingPeriods: true));
    final res = await _getAccountingPeriodsUseCase.call();
    res.fold(
      (failure) => emit(state.copyWith(isLoadingPeriods: false)),
      (periods) =>
          emit(state.copyWith(periods: periods, isLoadingPeriods: false)),
    );
  }

  void _onNameChanged(
    FinancialPeriodFormNameChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(periodName: event.value, errorMessage: null));
  }

  void _onStartDateChanged(
    FinancialPeriodFormStartDateChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(dateOfStartPeriod: event.value, errorMessage: null));
  }

  void _onEndDateChanged(
    FinancialPeriodFormEndDateChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(dateOfEndPeriod: event.value, errorMessage: null));
  }

  void _onLastPeriodIdChanged(
    FinancialPeriodFormLastPeriodIdChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(lastPeriodId: event.value, errorMessage: null));
  }

  void _onCurrencyChanged(
    FinancialPeriodFormCurrencyChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(currencyId: event.value, errorMessage: null));
  }

  void _onBalanceChanged(
    FinancialPeriodFormBalanceChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(balance: event.value, errorMessage: null));
  }

  void _onInventoryTypeChanged(
    FinancialPeriodFormInventoryTypeChanged event,
    Emitter<FinancialPeriodFormState> emit,
  ) {
    emit(state.copyWith(inventoryType: event.value, errorMessage: null));
  }

  Future<void> _onSubmitted(
    FinancialPeriodFormSubmitted event,
    Emitter<FinancialPeriodFormState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final balance =
          double.tryParse(state.balance.replaceAll(',', '.')) ?? 0.0;
      final int? lastPeriodId = state.lastPeriodId.isNotEmpty
          ? int.tryParse(state.lastPeriodId)
          : null;

      final entity = AccountingPeriodEntity(
        id: initialValue?.id ?? 0,
        periodName: state.periodName.trim(),
        dateOfStartPeriod: state.dateOfStartPeriod,
        dateOfEndPeriod: state.dateOfEndPeriod,
        lastPeriodId: lastPeriodId,
        currencyId: state.currencyId.trim(),
        balance: balance,
        inventoryType: state.inventoryType,
      );

      final Either<Failure, AccountingPeriodEntity> result =
          initialValue == null
          ? await _insertAccountingPeriodUseCase(entity)
          : await _updateAccountingPeriodUseCase(entity);

      result.fold(
        (failure) {
          emit(
            state.copyWith(isSubmitting: false, errorMessage: failure.message),
          );
        },
        (savedEntity) {
          emit(
            state.copyWith(
              isSubmitting: false,
              isSuccess: true,
              savedEntity: savedEntity,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'حدث خطأ أثناء الحفظ',
        ),
      );
    }
  }
}
