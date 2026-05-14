import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/presentation/login/bloc/login_bloc.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  const VerifyOtpScreen({super.key, required this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _localError;
  int _countDown = 60;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    startTime();
  }

  void startTime() {
    setState(() {
      _countDown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countDown == 0) {
        _timer?.cancel();
      } else {
        setState(() {
          _countDown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 36,
      height: 48,
      textStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        color: AppColors.blackText,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
      ),
    );
    final focusPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.buttonInsideLesson, width: 2),
        ),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.red, width: 2)),
      ),
    );
    return BlocConsumer<LoginBloc, LoginState>(
      builder: (context, state) {
        String? displayError =
            _localError ?? (state is LoginError ? state.message : null);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
            ),
            title: Text(
              'Đăng nhập bằng số điện thoại',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: RepaintBoundary(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Xác thực số điện thoại',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhập mã OTP từ tin nhắn',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      Pinput(
                        length: 6,
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusPinTheme,
                        errorPinTheme: errorPinTheme,
                        forceErrorState: displayError != null,
                        onChanged: (value) {
                          if (_localError != null) {
                            setState(() {
                              _localError = null;
                            });
                          }
                        },
                        onCompleted: (pin) {
                          context.read<LoginBloc>().add(VerifyOTP(pin));
                        },
                      ),
                      if (displayError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            displayError,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                                  if (_otpController.text.length < 6) {
                                    setState(() {
                                      _localError = 'Vui lòng nhập đủ 6 số OTP';
                                    });
                                  } else {
                                    context.read<LoginBloc>().add(
                                      VerifyOTP(_otpController.text),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonInsideLesson,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'XÁC NHẬN',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _countDown > 0
                          ? RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: AppColors.blackText,
                                ),
                                children: [
                                  const TextSpan(text: 'Vui lòng chờ '),
                                  TextSpan(
                                    text: '${_countDown}s',
                                    style: TextStyle(
                                      color: AppColors.karaokeText,
                                    ),
                                  ),
                                  const TextSpan(text: ' để lấy lại mã xác thực'),
                                ],
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                text: 'Gửi lại',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: AppColors.karaokeText,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  _otpController.clear();
                                  context.read<LoginBloc>().add(SendOTP(widget.phone));
                                }
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go('/lesson');
        } else if (state is OTPSent) {
          startTime();
        }
      },
    );
  }
}
