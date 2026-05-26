import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/presentation/rhythm_game/bloc/rhythm_game_bloc.dart';

import '../../../data/model/model.dart';

class _TapMark {
  final int timeMs;
  const _TapMark({required this.timeMs});
}

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

  final double hitZoneX = 100.0;
  final double pixelsPerMs = 0.2;

  String _feedbackText = '';
  bool _showFeedback = false;

  final List<_TapMark> _tapMarks = [];

  // Layout constants
  static const double gameAreaHeight = 260.0;
  static const double feedbackHeight = 28.0;
  static const double noteAreaTop = feedbackHeight + 8.0;
  static const double noteAreaHeight = 120.0;
  static const double barY = noteAreaTop + noteAreaHeight + 4.0;
  static const double barHeight = 4.0;

  @override
  void initState() {
    super.initState();
    _bloc = RhythmGameBloc(context.read<RhythmsRepository>(), FirebaseAuth.instance.currentUser!.uid, context.read<UserRepository>())
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

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    _bloc.close();
    super.dispose();
  }

  void _showFeedbackFlash(String text) {
    if (text.isEmpty) return;
    setState(() {
      _feedbackText = text;
      _showFeedback = true;
    });
  }

  Map<int, int> _buildNoteNumbers(List<Note> notes) {
    final map = <int, int>{};
    final measureCounters = <int, int>{};
    for (int i = 0; i < notes.length; i++) {
      final m = notes[i].measure;
      measureCounters[m] = (measureCounters[m] ?? 0) + 1;
      map[i] = measureCounters[m]!;
    }
    return map;
  }

  List<int> _getMeasureBoundaryTimes(List<Note> notes) {
    final boundaries = <int>[];
    int? lastMeasure;
    int? lastTimeMs;
    for (final note in notes) {
      if (lastMeasure != null && note.measure != lastMeasure) {
        final mid = ((lastTimeMs! + note.timeMs) / 2).round();
        boundaries.add(mid);
      }
      lastMeasure = note.measure;
      lastTimeMs = note.timeMs;
    }
    return boundaries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/rhythm'),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryText),
          title: Text(
            'Luyện nhịp điệu cơ bản',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.firstMainBackground,
                AppColors.secMainBackground,
              ],
            ),
          ),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return BlocListener<RhythmGameBloc, RhythmGameState>(
      listenWhen: (prev, curr) {
        if (prev is RhythmGameLoaded && curr is RhythmGameLoaded) {
          return prev.isPlaying != curr.isPlaying ||
              prev.tapCount != curr.tapCount;
        }
        if (curr is RhythmGameCompleted) return true;
        return false;
      },
      listener: (context, state) {
        if (state is RhythmGameLoaded) {
          if (state.isPlaying && !_ticker.isTicking) {
            _isFirstTick = true;
            _lastElapsed = Duration.zero;
            _ticker.start();
            setState(() => _tapMarks.clear());
          } else if (!state.isPlaying && _ticker.isTicking) {
            _ticker.stop();
          }

          if (state.feedbackText.isNotEmpty) {
            _showFeedbackFlash(state.feedbackText);

            // Prev tap
            final justTapped = state.notes.lastWhere(
              (n) => n.status != HitStatus.none,
              orElse: () => state.notes.first,
            );

            if (justTapped.status != HitStatus.perfect && justTapped.status != HitStatus.rest) {
              setState(() {
                _tapMarks.add(_TapMark(timeMs: state.currentTimeMs));
              });
            }
          }
        }
        if (state is RhythmGameCompleted) {
          _ticker.stop();
          context.go('/rhythm-result', extra: state.result);
        }
      },
      child: BlocBuilder<RhythmGameBloc, RhythmGameState>(
        builder: (context, state) {
          if (state is RhythmGameLoading || state is RhythmGameInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.progressColor),
            );
          }

          if (state is RhythmGameError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is RhythmGameLoaded) {
            final firstBeat = state.notes.firstWhere(
              (n) => n.type == NoteType.beat,
              orElse: () => state.notes.first,
            );
            final effectiveTime = state.isPlaying
                ? state.currentTimeMs
                : firstBeat.timeMs;
            final screenWidth = MediaQuery.of(context).size.width;
            final noteNumbers = _buildNoteNumbers(state.notes);
            final measureBoundaries = _getMeasureBoundaryTimes(state.notes);

            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      state.title,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// GAME AREA
                  SizedBox(
                    height: gameAreaHeight,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Feedback Text
                        Positioned(
                          left: hitZoneX - 80,
                          width: 160,
                          top: noteAreaTop - feedbackHeight - 4,
                          height: feedbackHeight,
                          child: AnimatedOpacity(
                            opacity: _showFeedback ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Center(
                              child: Text(
                                _feedbackText,
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Hit zone line
                        Positioned(
                          left: hitZoneX,
                          top: noteAreaTop,
                          child: Container(
                            width: 3,
                            height: noteAreaHeight + 4 + barHeight,
                            color: AppColors.progressColor,
                          ),
                        ),

                        // Thanh ngang
                        Positioned(
                          left: 0,
                          right: 0,
                          top: barY,
                          child: Container(
                            height: barHeight,
                            color: Colors.white12,
                          ),
                        ),

                        // Measure separator lines
                        ...measureBoundaries.map((boundaryTimeMs) {
                          final x =
                              hitZoneX +
                              (boundaryTimeMs - effectiveTime) * pixelsPerMs;
                          if (x < 0 || x > screenWidth) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            left: x - 1,
                            top: noteAreaTop,
                            child: Container(
                              width: 2,
                              height: noteAreaHeight + 4 + barHeight,
                              color: Colors.white30,
                            ),
                          );
                        }),

                        // Notes + tap marks + số thứ tự
                        ...() {
                          final widgets = <Widget>[];

                          // Tap marks
                          for (final mark in _tapMarks) {
                            final double markX =
                                hitZoneX +
                                (mark.timeMs - effectiveTime) * pixelsPerMs;

                            if (markX < -50 || markX > screenWidth + 50) {
                              continue;
                            }

                            const markWidth = 6.0;
                            const markHeight = 45.0;

                            widgets.add(
                              Positioned(
                                left: markX - markWidth / 2,
                                top:
                                    noteAreaTop +
                                    (noteAreaHeight - markHeight) / 2,
                                child: Container(
                                  width: markWidth,
                                  height: markHeight,
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonInsideLesson,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            );
                          }

                          // Notes
                          for (int i = 0; i < state.notes.length; i++) {
                            final note = state.notes[i];
                            final double noteX =
                                hitZoneX +
                                (note.timeMs - effectiveTime) * pixelsPerMs;

                            if (noteX < -50 || noteX > screenWidth + 50) {
                              continue;
                            }

                            final isBeat = note.type == NoteType.beat;
                            final noteWidth = 6.0;
                            final noteHeight = 45.0;
                            final noteY =
                                noteAreaTop + (noteAreaHeight - noteHeight) / 2;

                            Color tintColor;
                            switch (note.status) {
                              case HitStatus.perfect:
                                tintColor = AppColors.buttonInsideLesson;
                                break;
                              case HitStatus.miss:
                                tintColor = Colors.red;
                                break;
                              default:
                                tintColor = isBeat
                                    ? AppColors.noteColor
                                    : Colors.white38;
                            }

                            final noteNumber = noteNumbers[i] ?? 0;

                            // SVG note
                            widgets.add(
                              Positioned(
                                left: noteX - noteWidth / 2,
                                top: noteY,
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    tintColor,
                                    BlendMode.srcIn,
                                  ),
                                  child: SvgPicture.asset(
                                    isBeat
                                        ? 'assets/rhythms/beat.svg'
                                        : 'assets/rhythms/rest.svg',
                                    width: noteWidth,
                                    height: noteHeight,
                                  ),
                                ),
                              ),
                            );

                            // Số thứ tự
                            widgets.add(
                              Positioned(
                                top: noteY + noteHeight + 4,
                                left: noteX + 3,
                                child: Transform.translate(
                                  offset: const Offset(-5, 0),
                                  child: Text(
                                    '$noteNumber',
                                    style: GoogleFonts.roboto(
                                      fontSize: 10,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return widgets;
                        }(),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// BUTTON
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: GestureDetector(
                        onTapDown: (_) {
                          if (state.isPlaying) {
                            context.read<RhythmGameBloc>().add(Tap());
                          } else {
                            context.read<RhythmGameBloc>().add(StartGame());
                            context.read<RhythmGameBloc>().add(Tap());
                          }
                        },
                        onTapUp: (_) => setState(() => _showFeedback = false),
                        onTapCancel: () =>
                            setState(() => _showFeedback = false),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.progressColor,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            state.isPlaying ? 'Nhấn' : 'Bắt đầu',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
