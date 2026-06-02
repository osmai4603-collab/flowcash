import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/auth/domain/usecases/program_user_repository_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetProgramUsersUseCase _getAllUsers;
  final InsertProgramUserUseCase _addUser;
  final FirstWhereUserNameAndPasswordUseCase _authenticateUser;
  final UpdateProgramUserUseCase _updateUser;

  AuthBloc({
    required GetProgramUsersUseCase getAllUsers,
    required InsertProgramUserUseCase addUser,
    required FirstWhereUserNameAndPasswordUseCase authenticateUser,
    required UpdateProgramUserUseCase updateUser,
  })  : _getAllUsers = getAllUsers,
        _addUser = addUser,
        _authenticateUser = authenticateUser,
        _updateUser = updateUser,
        super(AuthState.initial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<AddUserEvent>(_onAddUser);
    on<AuthenticateUserEvent>(_onAuthenticateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _getAllUsers();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: failure.message)),
      (users) => emit(state.copyWith(status: AuthStatus.unauthenticated, users: users)),
    );
  }

  Future<void> _onAddUser(AddUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _addUser(event.user);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: failure.message)),
      (user) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, users: [...state.users, user]));
      },
    );
  }

  Future<void> _onAuthenticateUser(AuthenticateUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _authenticateUser(event.userName, event.password);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: failure.message)),
      (user) {
        if (user == null) {
          emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Invalid credentials'));
        } else {
          emit(state.copyWith(status: AuthStatus.authenticated, currentUser: user));
        }
      },
    );
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _updateUser(event.user);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, errorMessage: failure.message)),
      (user) {
        final updatedUsers = state.users.map((item) {
          return item.id == user.id ? user : item;
        }).toList();
        emit(state.copyWith(status: AuthStatus.unauthenticated, users: updatedUsers));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.unauthenticated, currentUser: null));
  }
}
