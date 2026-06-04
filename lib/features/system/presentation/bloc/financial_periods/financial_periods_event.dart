part of 'financial_periods_cubit.dart';

abstract class FinancialPeriodsEvent extends Equatable {
  const FinancialPeriodsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinancialPeriodsEvent extends FinancialPeriodsEvent {}
