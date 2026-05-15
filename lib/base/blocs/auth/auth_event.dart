part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AppStarted extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  final AppUser? user;
  _AuthUserChanged(this.user);
}

class AuthUserUpdate extends AuthEvent {
  final AppUser user;
  AuthUserUpdate(this.user);
}