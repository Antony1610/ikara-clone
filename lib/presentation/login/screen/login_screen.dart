import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
import 'package:ikara_clone/presentation/login/bloc/login_bloc.dart';
import '../../../constants/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginBloc(ctx.read<AuthRepository>()),
      child: const LoginPageView(),
    );
  }
}

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go('/lesson');
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.loginPageBackground,
        body: _LoginBody(),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48),

              /// LOGO
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 120,
                height: 120,
              ),

              const SizedBox(height: 12),

              /// TITLE
              SvgPicture.asset(
                'assets/icons/title.svg',
                height: 57,
                width: 174,
              ),

              const SizedBox(height: 24),

              const _SubtitleText(),

              const SizedBox(height: 28),

              const _LoginButtons(),

              const SizedBox(height: 28),

              const _PolicyText(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Đăng nhập để trải nghiệm các chức năng hoàn chỉnh',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }
}

class _LoginButtons extends StatelessWidget {
  const _LoginButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// PHONE LOGIN
        _LoginButton(
          onTap: () {
            context.push(
              '/phone-login',
            );
          },
          backgroundColor: AppColors.phoneNumberLogin,
          iconPath: 'assets/icons/phone.svg',
          iconColorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          label: 'Đăng nhập với SĐT',
          textColor: Colors.white,
        ),

        const SizedBox(height: 12),

        /// FACEBOOK LOGIN
        _LoginButton(
          onTap: () {
            context.read<LoginBloc>().add(FacebookSignInRequest());
          },
          backgroundColor: AppColors.facebookLogin,
          iconPath: 'assets/icons/facebook.svg',
          iconColorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          label: 'Đăng nhập với FB',
          textColor: Colors.white,
        ),

        const SizedBox(height: 12),

        /// GOOGLE LOGIN
        _LoginButton(
          onTap: () {
            context.read<LoginBloc>().add(GoogleSignInRequest());
          },
          backgroundColor: AppColors.googleLogin,
          borderSide: BorderSide(color: Colors.grey.shade300),
          iconPath: 'assets/icons/google.svg',
          label: 'Đăng nhập với Google',
          textColor: Colors.black87,
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    required this.backgroundColor,
    required this.iconPath,
    required this.label,
    required this.textColor,
    this.iconColorFilter,
    this.borderSide = BorderSide.none,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final String iconPath;
  final ColorFilter? iconColorFilter;
  final String label;
  final Color textColor;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black12,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
              colorFilter: iconColorFilter,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  const _PolicyText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11.5,
          color: Colors.black45,
        ),
        children: [
          const TextSpan(
            text: 'Tiếp tục sử dụng ứng dụng là bạn đồng ý với ',
          ),
          TextSpan(
            text: 'Chính sách\nriêng tư',
            style: TextStyle(color: Colors.blue.shade400),
          ),
          const TextSpan(text: ' và '),
          TextSpan(
            text: 'điều khoản sử dụng',
            style: TextStyle(color: Colors.blue.shade400),
          ),
          const TextSpan(text: ' của iKara'),
        ],
      ),
    );
  }
}