part of 'login_bloc.dart';

sealed class LoginEvent {}

class GoogleSignInRequest extends LoginEvent {}

class FacebookSignInRequest extends LoginEvent {}

class SendOTP extends LoginEvent {
  final String phone;
  SendOTP(this.phone);
}

class VerifyOTP extends LoginEvent {
  final String code;
  VerifyOTP(this.code);
}

class ResetLogin extends LoginEvent {}