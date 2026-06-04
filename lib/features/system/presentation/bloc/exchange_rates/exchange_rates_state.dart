part of 'exchange_rates_cubit.dart';

abstract class ExchangeRatesState extends Equatable {
  const ExchangeRatesState();
}

class ExchangeRatesInitial extends ExchangeRatesState {
  const ExchangeRatesInitial();

  @override
  List<Object?> get props => [];
}

class ExchangeRatesLoading extends ExchangeRatesState {
  const ExchangeRatesLoading();

  @override
  List<Object?> get props => [];
}

class ExchangeRatesSuccess extends ExchangeRatesState {
  final List<dynamic> items;

  const ExchangeRatesSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class ExchangeRatesFailure extends ExchangeRatesState {
  final String errorMessage;

  const ExchangeRatesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
