import 'package:equatable/equatable.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends AuthEvent {}

class AddUserEvent extends AuthEvent {
  final ProgramUserEntity user;

  const AddUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticateUserEvent extends AuthEvent {
  final String userName;
  final String password;

  const AuthenticateUserEvent({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

class UpdateUserEvent extends AuthEvent {
  final ProgramUserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class LogoutEvent extends AuthEvent {}
