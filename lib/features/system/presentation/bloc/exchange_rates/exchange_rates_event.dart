part of 'exchange_rates_cubit.dart';

abstract class ExchangeRatesEvent extends Equatable {
  const ExchangeRatesEvent();

  @override
  List<Object?> get props => [];
}

class LoadExchangeRatesEvent extends ExchangeRatesEvent {}
