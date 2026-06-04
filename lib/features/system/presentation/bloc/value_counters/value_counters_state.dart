part of 'value_counters_cubit.dart';

abstract class ValueCountersState extends Equatable {
  const ValueCountersState();
}

class ValueCountersInitial extends ValueCountersState {
  const ValueCountersInitial();

  @override
  List<Object?> get props => [];
}

class ValueCountersLoading extends ValueCountersState {
  const ValueCountersLoading();

  @override
  List<Object?> get props => [];
}

class ValueCountersSuccess extends ValueCountersState {
  final List<ValueCounterEntity> items;

  const ValueCountersSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class ValueCountersFailure extends ValueCountersState {
  final String errorMessage;

  const ValueCountersFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
