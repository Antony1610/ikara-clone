import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/model/user/app_user.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;
  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<LogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthUserUpdate>(_onAuthUserUpdate);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter emit) async {
    emit(AuthLoading());
    await _subscription?.cancel();
    _subscription = _repository.authStateChanges.listen(
      (user) {
        add(_AuthUserChanged(user));
      },
      onError: (e) {
        add(_AuthUserChanged(null));
      },
    );
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter emit) {
    final user = event.user;
    if (user == null) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user));
    }
  }
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter emit) async {
    try {
      await _repository.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter emit) async {
    try {
      await _repository.deleteAccount();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  void _onAuthUserUpdate(AuthUserUpdate event, Emitter emit) {
    emit(AuthAuthenticated(event.user));
  }
}
