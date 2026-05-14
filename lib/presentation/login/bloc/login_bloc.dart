import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _repository;

  LoginBloc(this._repository) : super(LoginInitial()) {
    on<GoogleSignInRequest>(_onGoogleSignInRequest);
    on<FacebookSignInRequest>(_onFacebookSignInRequest);
    on<SendOTP>(_onSendOTP);
    on<VerifyOTP>(_onVerifyOTP);
    on<ResetLogin>((event, emit) => emit(LoginInitial()));
  }

  Future<void> _onGoogleSignInRequest(
      GoogleSignInRequest event, Emitter emit) async {
    emit(LoginLoading());
    try {
      await _repository.loginWithGoogle();
      emit(LoginSuccess());
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        emit(const LoginError('Tài khoản đã bị xóa vĩnh viễn'));
      } else {
        emit(LoginError(e.toString()));
      }
    }
  }

  Future<void> _onFacebookSignInRequest(
      FacebookSignInRequest event, Emitter emit) async {
    emit(LoginLoading());
    try {
      await _repository.loginWithFacebook();
      emit(LoginSuccess());
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        emit(const LoginError('Tài khoản đã bị xóa vĩnh viễn'));
      } else {
        emit(LoginError(e.toString()));
      }
    }
  }

  Future<void> _onSendOTP(SendOTP event, Emitter emit) async {
    emit(LoginLoading());

    final completer = Completer<LoginState>();

    try {
      _repository.sendOTP(
        phoneNumber: event.phone,
        onCodeSent: (verificationId) {
          if (!completer.isCompleted) completer.complete(OTPSent());
        },
        onError: (error) {
          if (!completer.isCompleted) completer.complete(LoginError(error));
        },
        onAutoVerified: (credential) {
          if (!completer.isCompleted) completer.complete(LoginSuccess());
        },
      );

      final state = await completer.future;
      if (!emit.isDone) emit(state);
    } catch (e) {
      if (!emit.isDone) emit(LoginError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTP event, Emitter emit) async {
    emit(LoginLoading());
    try {
      await _repository.verifyOTP(event.code);
      emit(LoginSuccess());
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        emit(const LoginError('Tài khoản đã bị xóa vĩnh viễn'));
      } else {
        emit(LoginError(e.toString()));
      }
    }
  }
}