part of 'currencies_cubit.dart';

abstract class CurrenciesEvent extends Equatable {
  const CurrenciesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrenciesEvent extends CurrenciesEvent {}
