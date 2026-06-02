import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionUsersEvent extends SessionEvent {}

class LoginRequested extends SessionEvent {
  final String userName;
  final String password;

  const LoginRequested({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

class LogoutRequested extends SessionEvent {}
