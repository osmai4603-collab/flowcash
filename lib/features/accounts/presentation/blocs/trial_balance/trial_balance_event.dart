import 'package:equatable/equatable.dart';

abstract class TrialBalanceEvent extends Equatable {
  const TrialBalanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrialBalance extends TrialBalanceEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadTrialBalance({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
