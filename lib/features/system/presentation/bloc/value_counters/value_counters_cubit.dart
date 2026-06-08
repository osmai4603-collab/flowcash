import 'package:flowcash/features/settings/domain/entities/value_counter_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/features/settings/domain/entities/value_counter_entity.dart'
    as settings_entity;
import 'package:flowcash/features/settings/domain/usecases/counters/get_counter.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/increment_counter.dart';
import 'package:flowcash/features/settings/domain/usecases/counters/set_counter.dart';

part 'value_counters_state.dart';
part 'value_counters_event.dart';

class ValueCountersBloc extends Bloc<ValueCountersEvent, ValueCountersState> {
  final GetCounter _getCounter;
  final IncrementCounter _incrementCounter;
  final SetCounter _setCounter;

  ValueCountersBloc(this._getCounter, this._incrementCounter, this._setCounter)
    : super(const ValueCountersInitial()) {
    on<LoadValueCountersEvent>(_onLoad);
    on<IncrementValueCountersEvent>(_onIncrement);
    on<SetValueCountersEvent>(_onSet);
  }

  Future<void> _onLoad(
    LoadValueCountersEvent event,
    Emitter<ValueCountersState> emit,
  ) async {
    emit(const ValueCountersLoading());
    try {
      final List<settings_entity.ValueCounterEntity> items = [];
      for (final type in ValueCounterType.values) {
        final result = await _getCounter(type);
        result.fold((failure) {}, (counter) => items.add(counter));
      }
      emit(ValueCountersSuccess(items));
    } catch (e) {
      emit(ValueCountersFailure(e.toString()));
    }
  }

  Future<void> _onIncrement(
    IncrementValueCountersEvent event,
    Emitter<ValueCountersState> emit,
  ) async {
    emit(const ValueCountersLoading());
    final result = await _incrementCounter(event.counterType);
    result.fold(
      (failure) => emit(ValueCountersFailure(failure.message)),
      (value) => add(LoadValueCountersEvent()),
    );
  }

  Future<void> _onSet(
    SetValueCountersEvent event,
    Emitter<ValueCountersState> emit,
  ) async {
    emit(const ValueCountersLoading());
    final result = await _setCounter(event.counter);
    result.fold(
      (failure) => emit(ValueCountersFailure(failure.message)),
      (value) => add(LoadValueCountersEvent()),
    );
  }
}
