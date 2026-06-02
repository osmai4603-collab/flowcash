import 'package:equatable/equatable.dart';

abstract class AccountStatementEvent extends Equatable {
  const AccountStatementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountStatement extends AccountStatementEvent {
  final int subAccountId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAccountStatement({
    required this.subAccountId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [subAccountId, startDate, endDate];
}
