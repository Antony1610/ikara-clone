import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/practices_audio_repository.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/presentation/practices_details/bloc/practices_details_bloc.dart';
import 'package:ikara_clone/presentation/practices_details/widget/piano_note_drawn.dart';

class PracticesDetailsScreen extends StatefulWidget {
  final String id;
  const PracticesDetailsScreen({super.key, required this.id});

  @override
  State<PracticesDetailsScreen> createState() => _PracticesDetailsScreenState();
}

class _PracticesDetailsScreenState extends State<PracticesDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PracticesDetailsBloc(
        ctx.read<PracticesRepository>(),
        ctx.read<PracticesAudioRepository>(),
        ctx.read<UserRepository>(),
        FirebaseAuth.instance.currentUser!.uid,
      )..add(LoadPractices(widget.id)),
      child: Builder(
        builder: (context) => Scaffold(
          body: BlocListener<PracticesDetailsBloc, PracticesDetailsState>(
            listener: (context, state){
              if (state is FinishedPractices) {
                context.pushReplacement('/practices/${widget.id}/result', extra:{
                  'score' : state.score,
                  'practices' : state.practicesPart,
                  'status' : state.status
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.firstMainBackground,
                    AppColors.secMainBackground,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(children: [SafeArea(child: _body())]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<PracticesDetailsBloc, PracticesDetailsState>(
      buildWhen: (prev, cur) {
        if (cur is InitialPractices || cur is LoadingPractices || cur is ErrorPractices) return true;
        if (cur is! LoadedPractices) return false;
        if (prev is! LoadedPractices) return true;
        return prev.currentTimeMs != cur.currentTimeMs ||
            (prev.userPitchHz - cur.userPitchHz).abs() > 0.5 ||
            prev.isPlaying != cur.isPlaying ||
            prev.hitDuration != cur.hitDuration ||
            prev.hasStarted != cur.hasStarted ||
            prev.showOverlay != cur.showOverlay;
      },
      builder: (context, state) {
        if (state is InitialPractices || state is LoadingPractices) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.buttonInsideLesson,
            ),
          );
        }

        if (state is ErrorPractices) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (state is LoadedPractices) {
          final notes = state.notes;
          final minPitch = notes.map((n) => n.midiPitch).reduce(min) - 2;
          final maxPitch = notes.map((n) => n.midiPitch).reduce(max) + 2;
          return Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: SizedBox(
                    height: 500,
                    width: double.infinity,
                    child: AnimatedPiano(
                      notes: notes,
                      currentMs: state.currentTimeMs,
                      userPitchHz: state.userPitchHz,
                      hitDuration: state.hitDuration,
                      minPitch: minPitch,
                      maxPitch: maxPitch,
                      pxPerms: 0.2,
                      isPlaying: state.isPlaying,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.fourBackgroundPractices,
                        Colors.transparent,
                      ],
                      center: Alignment.bottomRight,
                      radius: 1.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      final bloc = context.read<PracticesDetailsBloc>();
                      if (state.isPlaying) {
                        bloc.add(PausePractices());
                      } else{
                        bloc.add(PlayPractices());
                      }
                    },
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: state.isPlaying
                            ? AppColors.pauseButton
                            : AppColors.buttonInsideLesson,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              if (state.showOverlay) _buildOverlay(context),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final bloc = context.read<PracticesDetailsBloc>();
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => bloc.add(ResumePractices()),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: AppColors.buttonInsideLesson,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => bloc.add(LoadPractices(widget.id)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: AppColors.buttonInsideLesson),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Bắt đầu lại',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/practices'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: AppColors.buttonInsideLesson),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Thoát',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
