import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flowcash/features/auth/domain/usecases/program_user_repository_usecases.dart';
import 'package:flowcash/user_session.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final GetProgramUsersUseCase _getAllUsers;
  final FirstWhereUserNameAndPasswordUseCase _authenticateUser;
  final UserSession _userSession;

  SessionBloc({
    required GetProgramUsersUseCase getAllUsers,
    required FirstWhereUserNameAndPasswordUseCase authenticateUser,
    required UserSession userSession,
  })  : _getAllUsers = getAllUsers,
        _authenticateUser = authenticateUser,
        _userSession = userSession,
        super(SessionState.initial()) {
    on<LoadSessionUsersEvent>(_onLoadUsers);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadUsers(
    LoadSessionUsersEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(status: SessionStatus.loading, errorMessage: null));

    final result = await _getAllUsers();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SessionStatus.failure,
        errorMessage: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: SessionStatus.unauthenticated,
        users: users,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(status: SessionStatus.loading, errorMessage: null));
    debugPrint('Attempting login for user: ${event.userName}');
    final result = await _authenticateUser(event.userName, event.password);
    debugPrint('Authentication result: $result');
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: SessionStatus.failure,
          errorMessage: failure.message,
        ));
        debugPrint('Login failed: ${failure.message}');
      },
      (user) async {
        if (user == null) {
          emit(state.copyWith(
            status: SessionStatus.failure,
            errorMessage: 'Invalid credentials',
          ));
          return;
        }
        try {
          await _userSession.initSession(user);
          emit(state.copyWith(
            status: SessionStatus.authenticated,
            currentUser: user,
            errorMessage: null,
          ));
          debugPrint('Login successful for user: ${user.userName}');
        } catch (error) {
          emit(state.copyWith(
            status: SessionStatus.failure,
            errorMessage: error.toString(),
          ));
          debugPrint('Session initialization failed: ${error.toString()}');
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    await _userSession.logout();
    emit(state.copyWith(
      status: SessionStatus.unauthenticated,
      currentUser: null,
      errorMessage: null,
    ));
  }
}
