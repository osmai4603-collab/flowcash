import 'package:equatable/equatable.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';

enum SessionStatus { initial, loading, authenticated, unauthenticated, failure }

class SessionState extends Equatable {
  final SessionStatus status;
  final ProgramUserEntity? currentUser;
  final List<ProgramUserEntity> users;
  final String? errorMessage;

  const SessionState({
    required this.status,
    this.currentUser,
    required this.users,
    this.errorMessage,
  });

  factory SessionState.initial() {
    return const SessionState(
      status: SessionStatus.initial,
      users: [],
      currentUser: null,
      errorMessage: null,
    );
  }

  SessionState copyWith({
    SessionStatus? status,
    ProgramUserEntity? currentUser,
    List<ProgramUserEntity>? users,
    String? errorMessage,
  }) {
    return SessionState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentUser, users, errorMessage];
}
