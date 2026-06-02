import 'package:equatable/equatable.dart';

abstract class GroupBalancesEvent extends Equatable {
  const GroupBalancesEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupBalances extends GroupBalancesEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupBalances({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
