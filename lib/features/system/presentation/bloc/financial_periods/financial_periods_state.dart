part of 'financial_periods_cubit.dart';

abstract class FinancialPeriodsState extends Equatable {
  const FinancialPeriodsState();
}

class FinancialPeriodsInitial extends FinancialPeriodsState {
  const FinancialPeriodsInitial();

  @override
  List<Object?> get props => [];
}

class FinancialPeriodsLoading extends FinancialPeriodsState {
  const FinancialPeriodsLoading();

  @override
  List<Object?> get props => [];
}

class FinancialPeriodsSuccess extends FinancialPeriodsState {
  final List<AccountingPeriodEntity> items;

  const FinancialPeriodsSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class FinancialPeriodsFailure extends FinancialPeriodsState {
  final String errorMessage;

  const FinancialPeriodsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
