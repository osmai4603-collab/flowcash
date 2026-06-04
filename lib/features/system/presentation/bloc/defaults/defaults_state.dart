part of 'defaults_cubit.dart';

abstract class DefaultsState extends Equatable {
  const DefaultsState();
}

class DefaultsInitial extends DefaultsState {
  const DefaultsInitial();

  @override
  List<Object?> get props => [];
}

class DefaultsLoading extends DefaultsState {
  const DefaultsLoading();

  @override
  List<Object?> get props => [];
}

class DefaultsSuccess extends DefaultsState {
  final List<ValueEntity> items;

  const DefaultsSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class DefaultsFailure extends DefaultsState {
  final String errorMessage;

  const DefaultsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
