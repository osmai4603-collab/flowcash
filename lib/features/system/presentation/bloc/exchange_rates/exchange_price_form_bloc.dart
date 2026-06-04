import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';

abstract class ExchangePriceFormEvent extends Equatable {
  const ExchangePriceFormEvent();

  @override
  List<Object?> get props => [];
}

class ExchangePriceFromCurrencyChanged extends ExchangePriceFormEvent {
  final String fromCurrencyId;

  const ExchangePriceFromCurrencyChanged(this.fromCurrencyId);

  @override
  List<Object?> get props => [fromCurrencyId];
}

class ExchangePriceToCurrencyChanged extends ExchangePriceFormEvent {
  final String toCurrencyId;

  const ExchangePriceToCurrencyChanged(this.toCurrencyId);

  @override
  List<Object?> get props => [toCurrencyId];
}

class ExchangePriceValueChanged extends ExchangePriceFormEvent {
  final String price;

  const ExchangePriceValueChanged(this.price);

  @override
  List<Object?> get props => [price];
}

class ExchangePriceFormSubmitted extends ExchangePriceFormEvent {
  const ExchangePriceFormSubmitted();
}

class ExchangePriceFormState extends Equatable {
  final String fromCurrencyId;
  final String toCurrencyId;
  final String price;
  final bool isSubmitting;
  final bool isSuccess;
  final ExchangePriceEntity? savedEntity;
  final String? errorMessage;

  const ExchangePriceFormState({
    required this.fromCurrencyId,
    required this.toCurrencyId,
    required this.price,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.savedEntity,
    this.errorMessage,
  });

  factory ExchangePriceFormState.initial(ExchangePriceEntity? initialValue) {
    return ExchangePriceFormState(
      fromCurrencyId: initialValue?.fromCurrencyId ?? '',
      toCurrencyId: initialValue?.toCurrencyId ?? '',
      price: initialValue != null ? initialValue.price.toString() : '',
    );
  }

  ExchangePriceFormState copyWith({
    String? fromCurrencyId,
    String? toCurrencyId,
    String? price,
    bool? isSubmitting,
    bool? isSuccess,
    ExchangePriceEntity? savedEntity,
    String? errorMessage,
  }) {
    return ExchangePriceFormState(
      fromCurrencyId: fromCurrencyId ?? this.fromCurrencyId,
      toCurrencyId: toCurrencyId ?? this.toCurrencyId,
      price: price ?? this.price,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      savedEntity: savedEntity ?? this.savedEntity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fromCurrencyId,
        toCurrencyId,
        price,
        isSubmitting,
        isSuccess,
        savedEntity,
        errorMessage,
      ];
}

class ExchangePriceFormBloc extends Bloc<ExchangePriceFormEvent, ExchangePriceFormState> {
  final ExchangePriceEntity? initialValue;
  final InsertExchangePriceUseCase _insertExchangePriceUseCase;
  final UpdateExchangePriceUseCase _updateExchangePriceUseCase;

  ExchangePriceFormBloc({
    required this.initialValue,
    required InsertExchangePriceUseCase insertExchangePriceUseCase,
    required UpdateExchangePriceUseCase updateExchangePriceUseCase,
  })  : _insertExchangePriceUseCase = insertExchangePriceUseCase,
        _updateExchangePriceUseCase = updateExchangePriceUseCase,
        super(ExchangePriceFormState.initial(initialValue)) {
    on<ExchangePriceFromCurrencyChanged>(_onFromCurrencyChanged);
    on<ExchangePriceToCurrencyChanged>(_onToCurrencyChanged);
    on<ExchangePriceValueChanged>(_onValueChanged);
    on<ExchangePriceFormSubmitted>(_onSubmitted);
  }

  void _onFromCurrencyChanged(
    ExchangePriceFromCurrencyChanged event,
    Emitter<ExchangePriceFormState> emit,
  ) {
    emit(state.copyWith(fromCurrencyId: event.fromCurrencyId, errorMessage: null));
  }

  void _onToCurrencyChanged(
    ExchangePriceToCurrencyChanged event,
    Emitter<ExchangePriceFormState> emit,
  ) {
    emit(state.copyWith(toCurrencyId: event.toCurrencyId, errorMessage: null));
  }

  void _onValueChanged(
    ExchangePriceValueChanged event,
    Emitter<ExchangePriceFormState> emit,
  ) {
    emit(state.copyWith(price: event.price, errorMessage: null));
  }

  Future<void> _onSubmitted(
    ExchangePriceFormSubmitted event,
    Emitter<ExchangePriceFormState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    if (state.fromCurrencyId.trim().isEmpty) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'الرجاء إدخال العملة المرسلة',
      ));
      return;
    }

    if (state.toCurrencyId.trim().isEmpty) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'الرجاء إدخال العملة المستقبلة',
      ));
      return;
    }

    final price = double.tryParse(state.price.trim());
    if (price == null) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'الرجاء إدخال سعر صرف صالح',
      ));
      return;
    }

    final entity = ExchangePriceEntity(
      id: initialValue?.id ?? 0,
      fromCurrencyId: state.fromCurrencyId.trim(),
      toCurrencyId: state.toCurrencyId.trim(),
      price: price,
    );

    final result = initialValue == null
        ? await _insertExchangePriceUseCase.call(entity)
        : await _updateExchangePriceUseCase.call(entity);

    result.match(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (savedEntity) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        savedEntity: savedEntity,
      )),
    );
  }
}
