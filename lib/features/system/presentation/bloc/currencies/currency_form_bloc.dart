import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';

abstract class CurrencyFormEvent extends Equatable {
  const CurrencyFormEvent();

  @override
  List<Object?> get props => [];
}

class CurrencyFormIdChanged extends CurrencyFormEvent {
  final String id;

  const CurrencyFormIdChanged(this.id);

  @override
  List<Object?> get props => [id];
}

class CurrencyFormNameChanged extends CurrencyFormEvent {
  final String name;

  const CurrencyFormNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class CurrencyFormSymbolChanged extends CurrencyFormEvent {
  final String symbol;

  const CurrencyFormSymbolChanged(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

class CurrencyFormIsDefaultChanged extends CurrencyFormEvent {
  final bool isDefault;

  const CurrencyFormIsDefaultChanged(this.isDefault);

  @override
  List<Object?> get props => [isDefault];
}

class CurrencyFormSubmitted extends CurrencyFormEvent {
  const CurrencyFormSubmitted();
}

class CurrencyFormState extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final bool isDefault;
  final bool isSubmitting;
  final bool isSuccess;
  final CurrencyEntity? savedEntity;
  final String? errorMessage;

  const CurrencyFormState({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isDefault,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.savedEntity,
    this.errorMessage,
  });

  factory CurrencyFormState.initial(CurrencyEntity? initialValue) {
    return CurrencyFormState(
      id: initialValue?.id ?? '',
      name: initialValue?.name ?? '',
      symbol: initialValue?.symbol ?? '',
      isDefault: initialValue?.isDefault ?? false,
    );
  }

  CurrencyFormState copyWith({
    String? id,
    String? name,
    String? symbol,
    bool? isDefault,
    bool? isSubmitting,
    bool? isSuccess,
    CurrencyEntity? savedEntity,
    String? errorMessage,
  }) {
    return CurrencyFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      savedEntity: savedEntity ?? this.savedEntity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    symbol,
    isDefault,
    isSubmitting,
    isSuccess,
    savedEntity,
    errorMessage,
  ];
}

class CurrencyFormBloc extends Bloc<CurrencyFormEvent, CurrencyFormState> {
  final CurrencyEntity? initialValue;
  final InsertCurrencyUseCase _insertCurrencyUseCase;
  final UpdateCurrencyUseCase _updateCurrencyUseCase;

  CurrencyFormBloc({
    required this.initialValue,
    required InsertCurrencyUseCase insertCurrencyUseCase,
    required UpdateCurrencyUseCase updateCurrencyUseCase,
  }) : _insertCurrencyUseCase = insertCurrencyUseCase,
       _updateCurrencyUseCase = updateCurrencyUseCase,
       super(CurrencyFormState.initial(initialValue)) {
    on<CurrencyFormIdChanged>(_onIdChanged);
    on<CurrencyFormNameChanged>(_onNameChanged);
    on<CurrencyFormSymbolChanged>(_onSymbolChanged);
    on<CurrencyFormIsDefaultChanged>(_onIsDefaultChanged);
    on<CurrencyFormSubmitted>(_onSubmitted);
  }

  void _onIdChanged(
    CurrencyFormIdChanged event,
    Emitter<CurrencyFormState> emit,
  ) {
    emit(state.copyWith(id: event.id, errorMessage: null));
  }

  void _onNameChanged(
    CurrencyFormNameChanged event,
    Emitter<CurrencyFormState> emit,
  ) {
    emit(state.copyWith(name: event.name, errorMessage: null));
  }

  void _onSymbolChanged(
    CurrencyFormSymbolChanged event,
    Emitter<CurrencyFormState> emit,
  ) {
    emit(state.copyWith(symbol: event.symbol, errorMessage: null));
  }

  void _onIsDefaultChanged(
    CurrencyFormIsDefaultChanged event,
    Emitter<CurrencyFormState> emit,
  ) {
    emit(state.copyWith(isDefault: event.isDefault, errorMessage: null));
  }

  Future<void> _onSubmitted(
    CurrencyFormSubmitted event,
    Emitter<CurrencyFormState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    if (state.id.trim().isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'الرجاء إدخال معرف العملة',
        ),
      );
      return;
    }

    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'الرجاء إدخال اسم العملة',
        ),
      );
      return;
    }

    final entity = CurrencyEntity(
      id: state.id.trim(),
      name: state.name.trim(),
      symbol: state.symbol.trim(),
      isDefault: state.isDefault,
    );

    final result = initialValue == null
        ? await _insertCurrencyUseCase.call(entity)
        : await _updateCurrencyUseCase.call(entity);

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
  }
}
