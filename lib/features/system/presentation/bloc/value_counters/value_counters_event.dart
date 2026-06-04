part of 'value_counters_cubit.dart';

abstract class ValueCountersEvent extends Equatable {
  const ValueCountersEvent();

  @override
  List<Object?> get props => [];
}

class LoadValueCountersEvent extends ValueCountersEvent {}

class IncrementValueCountersEvent extends ValueCountersEvent {
  final ValueCounterType counterType;

  const IncrementValueCountersEvent(this.counterType);

  @override
  List<Object?> get props => [counterType];
}

class SetValueCountersEvent extends ValueCountersEvent {
  final ValueCounterEntity counter;

  const SetValueCountersEvent(this.counter);

  @override
  List<Object?> get props => [counter];
}
