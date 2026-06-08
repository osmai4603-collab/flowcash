import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'defaults_state.dart';
part 'defaults_event.dart';

class DefaultsBloc extends Bloc<DefaultsEvent, DefaultsState> {
  DefaultsBloc() : super(const DefaultsInitial()) {
    on<LoadDefaultsEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDefaultsEvent event,
    Emitter<DefaultsState> emit,
  ) async {
    emit(const DefaultsLoading());
    await Future.delayed(const Duration(milliseconds: 50));
    emit(const DefaultsSuccess([]));
  }
}
