import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';

part 'default_value_form_state.dart';

class DefaultValueFormCubit extends Cubit<DefaultValueFormState> {
  DefaultValueFormCubit({ValueEntity? initial}) : super(DefaultValueFormInitial(initial));

  void submit(ValueEntity value) async {
    emit(DefaultValueFormSubmitting(state.initialValue));
    await Future.delayed(const Duration(milliseconds: 150));
    emit(DefaultValueFormSuccess(value));
  }
}
