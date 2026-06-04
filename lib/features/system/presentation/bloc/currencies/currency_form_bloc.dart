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

class CurrencyFormFullSymbolChanged extends CurrencyFormEvent {
  final String fullSymbol;

  const CurrencyFormFullSymbolChanged(this.fullSymbol);

  @override
  List<Object?> get props => [fullSymbol];
}

class CurrencyFormCountryChanged extends CurrencyFormEvent {
  final String country;

  const CurrencyFormCountryChanged(this.country);

  @override
  List<Object?> get props => [country];
}

class CurrencyFormSelectedChanged extends CurrencyFormEvent {
  final bool selected;

  const CurrencyFormSelectedChanged(this.selected);

  @override
  List<Object?> get props => [selected];
}

class CurrencyFormSubmitted extends CurrencyFormEvent {
  const CurrencyFormSubmitted();
}

class CurrencyFormState extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final String fullSymbol;
  final String country;
  final bool selected;
  final bool isSubmitting;
  final bool isSuccess;
  final CurrencyEntity? savedEntity;
  final String? errorMessage;

  const CurrencyFormState({
    required this.id,
    required this.name,
    required this.symbol,
    required this.fullSymbol,
    required this.country,
    required this.selected,
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
      fullSymbol: initialValue?.fullSymbol ?? '',
      country: initialValue?.country ?? '',
      selected: initialValue?.selected ?? false,
    );
  }

  CurrencyFormState copyWith({
    String? id,
    String? name,
    String? symbol,
    String? fullSymbol,
    String? country,
    bool? selected,
    bool? isSubmitting,
    bool? isSuccess,
    CurrencyEntity? savedEntity,
    String? errorMessage,
  }) {
    return CurrencyFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      fullSymbol: fullSymbol ?? this.fullSymbol,
      country: country ?? this.country,
      selected: selected ?? this.selected,
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
        fullSymbol,
        country,
        selected,
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
  })  : _insertCurrencyUseCase = insertCurrencyUseCase,
        _updateCurrencyUseCase = updateCurrencyUseCase,
        super(CurrencyFormState.initial(initialValue)) {
    on<CurrencyFormIdChanged>(_onIdChanged);
    on<CurrencyFormNameChanged>(_onNameChanged);
    on<CurrencyFormSymbolChanged>(_onSymbolChanged);
    on<CurrencyFormFullSymbolChanged>(_onFullSymbolChanged);
    on<CurrencyFormCountryChanged>(_onCountryChanged);
    on<CurrencyFormSelectedChanged>(_onSelectedChanged);
    on<CurrencyFormSubmitted>(_onSubmitted);
  }

  void _onIdChanged(CurrencyFormIdChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(id: event.id, errorMessage: null));
  }

  void _onNameChanged(CurrencyFormNameChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(name: event.name, errorMessage: null));
  }

  void _onSymbolChanged(CurrencyFormSymbolChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(symbol: event.symbol, errorMessage: null));
  }

  void _onFullSymbolChanged(CurrencyFormFullSymbolChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(fullSymbol: event.fullSymbol, errorMessage: null));
  }

  void _onCountryChanged(CurrencyFormCountryChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(country: event.country, errorMessage: null));
  }

  void _onSelectedChanged(CurrencyFormSelectedChanged event, Emitter<CurrencyFormState> emit) {
    emit(state.copyWith(selected: event.selected, errorMessage: null));
  }

  Future<void> _onSubmitted(CurrencyFormSubmitted event, Emitter<CurrencyFormState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    if (state.id.trim().isEmpty) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'الرجاء إدخال معرف العملة',
      ));
      return;
    }

    if (state.name.trim().isEmpty) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'الرجاء إدخال اسم العملة',
      ));
      return;
    }

    final entity = CurrencyEntity(
      id: state.id.trim(),
      name: state.name.trim(),
      symbol: state.symbol.trim(),
      fullSymbol: state.fullSymbol.trim(),
      country: state.country.trim(),
      selected: state.selected,
    );

    final result = initialValue == null
        ? await _insertCurrencyUseCase.call(entity)
        : await _updateCurrencyUseCase.call(entity);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (savedEntity) {
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          savedEntity: savedEntity,
        ));
      },
    );
  }
}
