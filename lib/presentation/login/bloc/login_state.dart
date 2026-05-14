part of 'login_bloc.dart';

sealed class LoginState extends Equatable{
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object> get props => [message];
}

class OTPSent extends LoginState {}
