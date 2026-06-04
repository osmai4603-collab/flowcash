part of 'currencies_cubit.dart';

abstract class CurrenciesState extends Equatable {
  const CurrenciesState();
}

class CurrenciesInitial extends CurrenciesState {
  const CurrenciesInitial();

  @override
  List<Object?> get props => [];
}

class CurrenciesLoading extends CurrenciesState {
  const CurrenciesLoading();

  @override
  List<Object?> get props => [];
}

class CurrenciesSuccess extends CurrenciesState {
  final List<dynamic> items;

  const CurrenciesSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class CurrenciesFailure extends CurrenciesState {
  final String errorMessage;

  const CurrenciesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
