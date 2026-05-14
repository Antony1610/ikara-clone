import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ikara_clone/constants/app_colors.dart';

import '../bloc/login_bloc.dart';



class PhoneNumberSendOtp extends StatefulWidget {
  const PhoneNumberSendOtp({super.key});

  @override
  State<PhoneNumberSendOtp> createState() => _PhoneNumberSendOtpState();
}

class _PhoneNumberSendOtpState extends State<PhoneNumberSendOtp> {
  final TextEditingController _phoneController = TextEditingController();
  String? _localError;



  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is OTPSent) {
          final bloc = context.read<LoginBloc>();
          final phone = _phoneController.text.trim();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.push(
              '/verify-otp',
              extra: {
                'phone': phone,
                'bloc': bloc,
              },
            ).then((_) {
              if (!mounted) return;
              bloc.add(ResetLogin());
              _phoneController.clear();
              setState(() => _localError = null);
            });
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.black,
            ),
            onPressed: () => context.pop(),
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
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: RepaintBoundary(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Bạn nhập số điện thoại để chúng\ntôi gửi mã xác thực',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
          
                const SizedBox(height: 50),
          
                /// ✅ TextField KHÔNG rebuild theo bloc
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    if (_localError != null) {
                      setState(() {
                        _localError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại',
                    hintStyle:  TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                    errorText: _localError,
                    errorStyle: const TextStyle(color: Colors.red),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
          
                const SizedBox(height: 24),
          
                /// ✅ Chỉ button rebuild khi state đổi
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is LoginLoading
                            ? null
                            : () {
                          String rawPhone =
                          _phoneController.text.trim();
          
                          final RegExp phoneRegex = RegExp(
                            r'^0[3|5|7|8|9][0-9]{8}$',
                          );
          
                          if (rawPhone.isEmpty) {
                            setState(() =>
                            _localError =
                            'Vui lòng nhập số điện thoại');
                          } else if (!phoneRegex.hasMatch(rawPhone)) {
                            setState(() =>
                            _localError =
                            'Số điện thoại không hợp lệ');
                          } else {
                            String formattedPhone =
                                '+84${rawPhone.substring(1)}';
          
                            setState(() => _localError = null);
          
                            context
                                .read<LoginBloc>()
                                .add(SendOTP(formattedPhone));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.buttonInsideLesson,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is LoginLoading
                            ? const Padding(
                          padding: EdgeInsets.all(8),
                          child:
                          CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
                          'GỬI OTP',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}