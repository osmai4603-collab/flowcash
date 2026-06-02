import 'package:equatable/equatable.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final List<ProgramUserEntity> users;
  final ProgramUserEntity? currentUser;
  final String? errorMessage;

  const AuthState({
    required this.status,
    required this.users,
    this.currentUser,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      users: [],
      currentUser: null,
      errorMessage: null,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    List<ProgramUserEntity>? users,
    ProgramUserEntity? currentUser,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, currentUser, errorMessage];
}
