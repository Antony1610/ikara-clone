import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'dart:async';

import '../../../data/model/model.dart';
import '../widget/rhythm_painter.dart';
import '../bloc/rhythm_game_bloc.dart';

class RhythmGameScreen extends StatefulWidget {
  final String id;
  const RhythmGameScreen({super.key, required this.id});

  @override
  State<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends State<RhythmGameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late RhythmGameBloc _bloc;

  bool _isFirstTick = true;
  Duration _lastElapsed = Duration.zero;

  bool _showFeedback = false;
  String _feedbackText = '';
  Timer? _feedbackTimer;

  final double hitZoneX = 100.0;
  final double pixelsPerMs = 0.2;

  List<Note>? _cachedNotes;

  @override
  void initState() {
    super.initState();

    _bloc = RhythmGameBloc(context.read<RhythmsRepository>())
      ..add(LoadGame(widget.id));

    _ticker = createTicker((elapsed) {
      if (_isFirstTick) {
        _lastElapsed = elapsed;
        _isFirstTick = false;
        return;
      }

      final delta = (elapsed - _lastElapsed).inMilliseconds;
      _lastElapsed = elapsed;

      if (_ticker.isTicking) {
        _bloc.add(UpdateTick(delta));
      }
    });
  }

  void _triggerFeedback(String text) {
    setState(() {
      _showFeedback = true;
      _feedbackText = text;
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _showFeedback = false);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _feedbackTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  void _updatePrecomputeIfNeeded(List<Note> notes) {
    if (_cachedNotes == notes) return;
    _cachedNotes = notes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.go('/rhythm'),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Luyện nhịp điệu cơ bản',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.firstMainBackground,
                AppColors.secMainBackground,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return MultiBlocListener(
      listeners: [
        /// START / STOP ticker
        BlocListener<RhythmGameBloc, RhythmGameState>(
          listenWhen: (p, c) =>
          p is RhythmGameLoaded &&
              c is RhythmGameLoaded &&
              p.isPlaying != c.isPlaying,
          listener: (context, state) {
            if (state is RhythmGameLoaded) {
              if (state.isPlaying) {
                _isFirstTick = true;
                _ticker.start();
              } else {
                _ticker.stop();
              }
            }
          },
        ),

        /// FEEDBACK
        BlocListener<RhythmGameBloc, RhythmGameState>(
          listenWhen: (p, c) =>
          c is RhythmGameLoaded &&
              p is RhythmGameLoaded &&
              c.tapCount > p.tapCount,
          listener: (context, state) {
            if (state is RhythmGameLoaded) {
              _triggerFeedback(state.feedbackText);
            }
          },
        ),

        /// COMPLETE
        BlocListener<RhythmGameBloc, RhythmGameState>(
          listenWhen: (p, c) => c is RhythmGameCompleted,
          listener: (context, state) {
            if (state is RhythmGameCompleted) {
              context.pushReplacement('/rhythm-result', extra: state.result);
            }
          },
        ),
      ],
      child: BlocBuilder<RhythmGameBloc, RhythmGameState>(
        buildWhen: (p, c) =>
        c is RhythmGameLoaded ||
            c is RhythmGameError ||
            c is RhythmGameLoading,
        builder: (context, state) {
          if (state is RhythmGameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RhythmGameError) {
            return Center(child: Text(state.message));
          }

          if (state is RhythmGameLoaded) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Text(
                    state.title,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const Spacer(),

                  _GameArea(
                    hitZoneX: hitZoneX,
                    pixelsPerMs: pixelsPerMs,
                    onPrecompute: _updatePrecomputeIfNeeded,
                  ),

                  /// Feedback overlay
                  AnimatedOpacity(
                    opacity: _showFeedback ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      _feedbackText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (state.isPlaying) {
                            context.read<RhythmGameBloc>().add(Tap());
                          } else {
                            context.read<RhythmGameBloc>().add(StartGame());
                            context.read<RhythmGameBloc>().add(Tap());
                          }
                        },
                        child: Text(
                          state.isPlaying ? 'Nhấn' : 'Nhấn để bắt đầu',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _GameArea extends StatelessWidget {
  final double hitZoneX;
  final double pixelsPerMs;
  final Function(List<Note>) onPrecompute;

  const _GameArea({
    required this.hitZoneX,
    required this.pixelsPerMs,
    required this.onPrecompute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RhythmGameBloc, RhythmGameState, RhythmGameLoaded?>(
      selector: (state) =>
      state is RhythmGameLoaded ? state : null,
      builder: (context, state) {
        if (state == null) return const SizedBox(height: 160);

        onPrecompute(state.notes);

        return SizedBox(
          height: 160,
          width: double.infinity,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: RhythmPainter(
                notes: state.notes,
                currentTime: state.currentTimeMs,
                hitZoneX: hitZoneX,
                pixelsPerMs: pixelsPerMs,
              ),
            ),
          ),
        );
      },
    );
  }
}