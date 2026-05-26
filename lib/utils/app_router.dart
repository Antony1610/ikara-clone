import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/base/blocs/auth/auth_bloc.dart';

import 'package:ikara_clone/presentation/breathing_lesson/screen/breathing_lesson_screen.dart';
import 'package:ikara_clone/presentation/breathing_lesson_result/screen/breathing_lesson_result_screen.dart';
import 'package:ikara_clone/presentation/cancel_account/screen/cancel_account_screen.dart';
import 'package:ikara_clone/presentation/home/screen/home_screen.dart';
import 'package:ikara_clone/presentation/lesson_detail/screen/lesson_detail_page_screen.dart';
import 'package:ikara_clone/presentation/lesson/screen/lesson_page_screen.dart';
import 'package:ikara_clone/presentation/login/screen/login_screen.dart';
import 'package:ikara_clone/presentation/performance_detail/screen/performance_detail_screen.dart';
import 'package:ikara_clone/presentation/performance_karaoke/screen/performance_karaoke_screen.dart';
import 'package:ikara_clone/presentation/performances/screen/performance_screen.dart';
import 'package:ikara_clone/presentation/practices/screen/practices_screen.dart';
import 'package:ikara_clone/presentation/profile/screen/profile_screen.dart';
import 'package:ikara_clone/presentation/report_error/screen/report_error_screen.dart';
import 'package:ikara_clone/presentation/rhythm_game/screen/rhythm_game_screen.dart';
import 'package:ikara_clone/presentation/rhythm_training/screen/rhythm_training_screen.dart';
import 'package:ikara_clone/presentation/rhythm_game_result/screen/rhythm_game_result_screen.dart';
import 'package:ikara_clone/constants/constants.dart';

import '../data/model/model.dart';

import '../data/model/user/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../presentation/breathing_lesson_detail/screen/breathing_lesson_detail_screen.dart';
import '../presentation/lesson_question_result/screen/lesson_result_screen.dart';
import '../presentation/login/bloc/login_bloc.dart';
import '../presentation/login/screen/phone_number_send_otp.dart';
import '../presentation/login/screen/verify_otp_screen.dart';
import '../presentation/practices_details/screen/practices_details_screen.dart';
import '../presentation/practices_results/screen/practices_results_screen.dart';
import '../presentation/profile/bloc/profile_bloc.dart';
import '../presentation/setting/screen/setting_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: AppTransitions.fadeOutIn,
          transitionDuration: Duration(milliseconds: 600),
        ),
      ),
      GoRoute(
        path: '/phone-login',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (ctx) => LoginBloc(ctx.read<AuthRepository>()),
              child: const PhoneNumberSendOtp(),
            ),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/verify-otp',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final loginBloc = extraData['bloc'] as LoginBloc;
          final phone = extraData['phone'] as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider.value(
              value: loginBloc,
              child: VerifyOtpScreen(phone: phone),
            ),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        pageBuilder: (context, state, navigationShell) => CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(navigationShell: navigationShell),
          transitionsBuilder: AppTransitions.fadeOutIn,
          transitionDuration: Duration(milliseconds: 600),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lesson',
                builder: (context, state) => const LessonPageScreen(),
                routes: [
                  GoRoute(
                    path: ':lessonDocId',
                    builder: (context, state) => const LessonPageScreen(),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practices',
                builder: (context, state) => const PracticesScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/breathing',
                builder: (context, state) => const BreathingLessonScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rhythm',
                builder: (context, state) => const RhythmTrainingScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/performance',
                builder: (context, state) => const PerformanceScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/rhythm/:partId',
        pageBuilder: (context, state) {
          final partId = state.pathParameters['partId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: RhythmGameScreen(id: partId),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/rhythm-result',
        pageBuilder: (context, state) {
          final result = state.extra as RhythmsResult;
          return CustomTransitionPage(
            child: RhythmGameResultScreen(result: result),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/performanceDetail/:performanceId',
        pageBuilder: (context, state) {
          final performanceId = state.pathParameters['performanceId']!;
          return CustomTransitionPage(
            child: PerformanceDetailScreen(id: performanceId),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/lessonDetail/:partId/:lessonId',
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          final partId = state.pathParameters['partId']!;
          return CustomTransitionPage(
            child: LessonDetailPageScreen(partId: partId, lessonId: lessonId),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/lesson-result',
        pageBuilder: (context, state) {
          final result = state.extra as LessonResult;
          return CustomTransitionPage(
            child: LessonResultScreen(result: result),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/breathingDetail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BreathingLessonDetailScreen(id: id),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/breathing-result',
        pageBuilder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BreathingLessonResultScreen(
              id: data['id'] as String,
              score: (data['score'] as num).toInt(),
              type: data['type'] as String,
              duration: data['duration'],
            ),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/karaoke/:performanceId',
        pageBuilder: (context, state) {
          final performanceId = state.pathParameters['performanceId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PerformanceKaraokeScreen(id: performanceId),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),
      GoRoute(
        path: '/setting',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingScreen(),
          transitionsBuilder: AppTransitions.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) {
          final user = state.extra as AppUser?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (ctx) => ProfileBloc(
                ctx.read<AuthRepository>(),
                ctx.read<UserRepository>(),
                ctx.read<AuthBloc>(),
              ),
              child: ProfileScreen(user: user!),
            ),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),
      GoRoute(
        path: '/report-bug',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ReportErrorScreen(),
          transitionsBuilder: AppTransitions.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/cancel-account',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: CancelAccountScreen(),
          transitionsBuilder: AppTransitions.slideFromRight,
        ),
      ),
      GoRoute(
        path: '/practices/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PracticesDetailsScreen(id: id),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),
      GoRoute(
        path: '/practices/:id/result',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PracticesResultsScreen(
              score: extra['score'] as int,
              practicesPart: extra['practices'] as PracticesPart,
              status: extra['status'] as String,
            ),
            transitionsBuilder: AppTransitions.slideFromRight,
          );
        },
      ),
    ],
  );
}
