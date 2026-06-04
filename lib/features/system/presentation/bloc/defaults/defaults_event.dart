part of 'defaults_cubit.dart';

abstract class DefaultsEvent extends Equatable {
  const DefaultsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDefaultsEvent extends DefaultsEvent {}
