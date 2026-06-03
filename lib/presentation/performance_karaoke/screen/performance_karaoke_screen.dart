import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import 'package:ikara_clone/presentation/performance_karaoke/bloc/performance_karaoke_bloc.dart';
import '../../../data/repositories/karaoke_audio_repository.dart';
import '../widget/karaoke_lyrics_widget.dart';
import '../widget/piano_grid_painter.dart';

class PerformanceKaraokeScreen extends StatefulWidget {
  final String id;
  const PerformanceKaraokeScreen({super.key, required this.id});

  @override
  State<PerformanceKaraokeScreen> createState() =>
      _PerformanceKaraokeScreenState();
}

class _PerformanceKaraokeScreenState extends State<PerformanceKaraokeScreen> {
  bool isExpanded = false;
  final ValueNotifier<int> _currentMsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _userPitchNotifier = ValueNotifier<double>(0.0);
  StreamSubscription? _posSub;
  StreamSubscription? _pitchSub;

  // Lưu reference sớm để dùng trong dispose an toàn
  late final KaraokeAudioRepository _audioRepo;

  @override
  void initState() {
    super.initState();
    _audioRepo = context.read<KaraokeAudioRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _pitchSub?.cancel();
    _audioRepo.stop();
    _currentMsNotifier.dispose();
    _userPitchNotifier.dispose();
    super.dispose();
  }

  void _startListening(BuildContext context) {
    _posSub?.cancel();
    _pitchSub?.cancel();

    final bloc = context.read<PerformanceKaraokeBloc>();

    _posSub = _audioRepo.positionStream.listen((pos) {
      bloc.add(UpdatePosition(pos.inMilliseconds));
      _currentMsNotifier.value = pos.inMilliseconds;
    });

    _pitchSub = _audioRepo.pitchStream.listen((pitch) {
      bloc.add(UpdatePitch(pitch));
      _userPitchNotifier.value = pitch;
    });
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        alignment: Alignment.center,
        content: Text(
          'Bạn chắc chắn muốn thoát không?',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.roboto(
                    color: AppColors.lockText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ctx.pop(true),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.roboto(
                    color: AppColors.buttonInsideLesson,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      context.pushReplacement('/performanceDetail/${widget.id}');
    }
  }

  Future<void> _showRetryDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        alignment: Alignment.center,
        content: Text(
          'Bạn có chắc chắn muốn bắt đầu lại không?',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.roboto(
                    color: AppColors.lockText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ctx.pop(true),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.roboto(
                    color: AppColors.buttonInsideLesson,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _posSub?.cancel();
      _pitchSub?.cancel();
      _posSub = null;
      _pitchSub = null;
      setState(() => isExpanded = false);
      context.read<PerformanceKaraokeBloc>().add(LoadPerformance(widget.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      },
      child: BlocProvider(
        create: (ctx) => PerformanceKaraokeBloc(
          repository: ctx.read<PerformanceRepository>(),
          karaokeAudioRepository: ctx.read<KaraokeAudioRepository>(),
        )..add(LoadPerformance(widget.id)),
        child: Builder(
          builder: (context) =>
              BlocListener<PerformanceKaraokeBloc, PerformanceKaraokeState>(
                listener: (context, state) {
                  if (state is LoadedKaraoke && _posSub == null) {
                    _startListening(context);
                  }
                  if (state is CompletedKaraoke) {
                    _posSub?.cancel();
                    _pitchSub?.cancel();
                    _posSub = null;
                    _pitchSub = null;
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                    context.pushReplacement(
                      '/performance/${widget.id}/result',
                      extra: {'score': state.score},
                    );
                  }
                },
                child: Scaffold(
                  body: Container(
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
                    child: Stack(
                      children: [
                        SafeArea(child: _body(context)),
                        Positioned(
                          top: 16,
                          left: 20,
                          child: SafeArea(child: _buildControl(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return BlocBuilder<PerformanceKaraokeBloc, PerformanceKaraokeState>(
      buildWhen: (prev, curr) {
        if (prev.runtimeType != curr.runtimeType) return true;
        if (prev is LoadedKaraoke && curr is LoadedKaraoke) {
          return prev.isPlaying != curr.isPlaying ||
              prev.userPitchHz != curr.userPitchHz ||
              prev.hitDuration != curr.hitDuration;
        }
        return false;
      },
      builder: (context, state) {
        if (state is LoadingKaraoke || state is InitialKaraoke) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }
        if (state is ErrorKaraoke) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (state is! LoadedKaraoke) {
          return const Center(
            child: Text('No data', style: TextStyle(color: Colors.white)),
          );
        }
        final loadedState = state;
        return Column(
          children: [
            Expanded(
              flex: 4,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _currentMsNotifier,
                  _userPitchNotifier,
                ]),
                builder: (context, _) {
                  return AnimatedPianoGrid(
                    notes: loadedState.song.notes,
                    currentMs: _currentMsNotifier.value,
                    userPitchHz: _userPitchNotifier.value,
                    hitDurations: loadedState.hitDuration,
                    minPitch: loadedState.minPitch,
                    maxPitch: loadedState.maxPitch,
                    pxPerms: 0.2,
                    isPlaying: loadedState.isPlaying,
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: RepaintBoundary(
                child: KaraokeLyricsWidget(
                  tokens: loadedState.song.lyrics,
                  currentMsNotifier: _currentMsNotifier,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControl(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isExpanded
          ? Row(
              key: const ValueKey('expanded'),
              children: [
                _buildCircleButton(
                  Icons.play_arrow,
                  'Tiếp tục',
                  onTap: () => _resume(context),
                ),
                const SizedBox(width: 12),
                _buildCircleButton(
                  Icons.refresh,
                  'Thử lại',
                  onTap: () => _showRetryDialog(context),
                ),
                const SizedBox(width: 12),
                _buildCircleButton(
                  Icons.exit_to_app,
                  'Thoát',
                  onTap: () => _showExitDialog(context),
                ),
              ],
            )
          : GestureDetector(
              key: const ValueKey('collapsed'),
              onTap: () => _pause(context),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.pause, color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _pause(BuildContext context) {
    context.read<PerformanceKaraokeBloc>().add(PauseKaraoke());
    if (mounted) setState(() => isExpanded = true);
  }

  void _resume(BuildContext context) {
    context.read<PerformanceKaraokeBloc>().add(ResumeKaraoke());
    if (mounted) setState(() => isExpanded = false);
  }
}
