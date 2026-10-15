import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

// ---------- Events ----------

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Se dispara al arrancar la app para restaurar la sesión.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// ---------- State ----------

enum AuthStatus { unknown, authenticated, unauthenticated }

final class AuthState extends Equatable {
  const AuthState._(this.status, [this.user]);

  const AuthState.unknown() : this._(AuthStatus.unknown);
  const AuthState.authenticated(User user)
    : this._(AuthStatus.authenticated, user);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated);

  final AuthStatus status;
  final User? user;

  @override
  List<Object?> get props => [status, user];
}

// ---------- Bloc ----------

/// Bloc GLOBAL de sesión. El router escucha su estado para redirigir.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required GetCurrentUser getCurrentUser, required Logout logout})
    : _getCurrentUser = getCurrentUser,
      _logout = logout,
      super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoggedIn>(
      (event, emit) => emit(AuthState.authenticated(event.user)),
    );
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentUser _getCurrentUser;
  final Logout _logout;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUser(const NoParams());
    emit(
      result.fold(
        (_) => const AuthState.unauthenticated(),
        (user) => user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}
