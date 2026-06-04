part of 'default_value_form_cubit.dart';

abstract class DefaultValueFormState extends Equatable {
  final ValueEntity? initialValue;
  const DefaultValueFormState(this.initialValue);

  @override
  List<Object?> get props => [initialValue];
}

class DefaultValueFormInitial extends DefaultValueFormState {
  const DefaultValueFormInitial(ValueEntity? initial) : super(initial);
}

class DefaultValueFormSubmitting extends DefaultValueFormState {
  const DefaultValueFormSubmitting(ValueEntity? initial) : super(initial);
}

class DefaultValueFormSuccess extends DefaultValueFormState {
  final ValueEntity value;
  const DefaultValueFormSuccess(this.value) : super(null);

  @override
  List<Object?> get props => [value];
}
