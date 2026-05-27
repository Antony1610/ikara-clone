import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikara_clone/base/app_bloc_observer.dart';
import 'package:ikara_clone/data/repositories/audio_repository.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/data/repositories/impl/audio_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/auth_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/breaths_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/karaoke_audio_repository_impl.dart';

import 'package:ikara_clone/data/repositories/impl/lessons_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/midi_parse_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/performance_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/practices_audio_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/practices_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/rhythms_repository_impl.dart';
import 'package:ikara_clone/data/repositories/impl/user_repository_impl.dart';
import 'package:ikara_clone/data/repositories/karaoke_audio_repository.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/repositories/midi_parse_repository.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import 'package:ikara_clone/data/repositories/practices_audio_repository.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/data/services/audio_service.dart';
import 'package:ikara_clone/data/services/auth_service.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/data/services/karaoke_audio_service.dart';
import 'package:ikara_clone/data/services/practices_audio_service.dart';
import 'package:ikara_clone/data/services/storage_service.dart';
import 'package:ikara_clone/data/services/user_service.dart';
import 'package:ikara_clone/firebase_options.dart';
import 'package:ikara_clone/presentation/home/bloc/bottom_navigator_bloc.dart';
import 'package:ikara_clone/utils/app_router.dart';

import 'base/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fb.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService().initialize();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => Dio()),
        RepositoryProvider<FirebaseService>(create: (_) => FirebaseService()),
        RepositoryProvider<AuthService>(create: (_) => AuthService()),
        RepositoryProvider<UserService>(create: (_) => UserService()),
        RepositoryProvider<StorageService>(create: (_) => StorageService()),
        RepositoryProvider<AudioService>(create: (_) => AudioService()),
        RepositoryProvider<PracticesAudioService>(create: (_) => PracticesAudioService()),
        RepositoryProvider<KaraokeAudioService>(
          create: (_) => KaraokeAudioService(),
        ),
        RepositoryProvider<LessonsRepository>(
          create: (context) =>
              LessonsRepositoryImpl(context.read<FirebaseService>()),
        ),
        RepositoryProvider<PerformanceRepository>(
          create: (context) =>
              PerformanceRepositoryImpl(context.read<FirebaseService>()),
        ),
        RepositoryProvider<BreathsRepository>(
          create: (context) =>
              BreathsRepositoryImpl(context.read<FirebaseService>()),
        ),
        RepositoryProvider<RhythmsRepository>(
          create: (context) =>
              RhythmsRepositoryImpl(context.read<FirebaseService>()),
        ),
        RepositoryProvider<PracticesRepository>(
          create: (context) =>
              PracticesRepositoryImpl(context.read<FirebaseService>()),
        ),

        RepositoryProvider<AudioRepository>(
          create: (context) =>
              AudioRepositoryImpl(context.read<AudioService>()),
        ),
        RepositoryProvider<KaraokeAudioRepository>(
          create: (context) =>
              KaraokeAudioRepositoryImpl(context.read<KaraokeAudioService>()),
        ),

        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),

        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(
            context.read<UserService>(),
            context.read<StorageService>(),
            context.read<FirebaseService>()
          ),
        ),
        RepositoryProvider<PracticesAudioRepository>(
          create: (context) => PracticesAudioRepositoryImpl(
            context.read<PracticesAudioService>(),
          ),
        ),
        RepositoryProvider<MidiParseRepository>(create: (context) => MidiParseRepositoryImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => BottomNavigatorBloc(),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            )..add(AppStarted()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ikara',
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
