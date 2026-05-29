import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ikara_clone/constants/constants.dart';
import '../../../data/model/performances/midi_note.dart';

class AnimatedPianoGrid extends StatefulWidget {
  final List<MidiNote> notes;
  final int currentMs;
  final double userPitchHz;
  final Map<int, double> hitDurations;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;
  final bool isPlaying;

  const AnimatedPianoGrid({
    super.key,
    required this.notes,
    required this.currentMs,
    required this.userPitchHz,
    required this.hitDurations,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
    required this.isPlaying,
  });

  @override
  State<AnimatedPianoGrid> createState() => _AnimatedPianoGridState();
}

class _AnimatedPianoGridState extends State<AnimatedPianoGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _smoothMsNotifier = ValueNotifier<double>(0);
  final _userPitchNotifier = ValueNotifier<double>(0);
  final _hitDurationNotifier = ValueNotifier<Map<int, double>>({});

  int _baseMs = 0;
  Duration _baseElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _baseMs = widget.currentMs;
    _smoothMsNotifier.value = widget.currentMs.toDouble();
    _userPitchNotifier.value = widget.userPitchHz;
    _hitDurationNotifier.value = widget.hitDurations;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(_onTick);

    if (widget.isPlaying) _controller.forward();
  }

  void _onTick() {
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    final ms = _baseMs + (elapsed - _baseElapsed).inMilliseconds;
    _smoothMsNotifier.value = ms.toDouble();
  }

  @override
  void didUpdateWidget(AnimatedPianoGrid old) {
    super.didUpdateWidget(old);

    if (old.currentMs != widget.currentMs) {
      _baseMs = widget.currentMs;
      _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
    }

    if (old.userPitchHz != widget.userPitchHz) {
      _userPitchNotifier.value = widget.userPitchHz;
    }

    if (old.hitDurations != widget.hitDurations) {
      _hitDurationNotifier.value = widget.hitDurations;
    }

    if (old.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _baseMs = widget.currentMs;
        _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    _smoothMsNotifier.dispose();
    _userPitchNotifier.dispose();
    _hitDurationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: PianoGridPainter(
          notes: widget.notes,
          smoothMsListenable: _smoothMsNotifier,
          userPitchListenable: _userPitchNotifier,
          hitDurationsListenable: _hitDurationNotifier,
          minPitch: widget.minPitch,
          maxPitch: widget.maxPitch,
          pxPerms: widget.pxPerms,
        ),
      ),
    );
  }
}

class PianoGridPainter extends CustomPainter {
  final List<MidiNote> notes;
  final ValueNotifier<double> smoothMsListenable;
  final ValueNotifier<double> userPitchListenable;
  final ValueNotifier<Map<int, double>> hitDurationsListenable;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;

  double _cachedPitchHz = 0;
  double _cachedUserMidi = 0;

  static final _playheadPaint = Paint()
    ..color = AppColors.buttonInsideLesson
    ..strokeWidth = 2;

  static final _paintUpcoming = Paint()
    ..color = Colors.white24
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  static final _paintSung = Paint()
    ..color = AppColors.buttonInsideLesson
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  static final _paintUserDot = Paint()..color = Colors.white;

  static const double _strokeRadius = 5.0; // strokeWidth / 2 = 10 / 2

  PianoGridPainter({
    required this.notes,
    required this.smoothMsListenable,
    required this.userPitchListenable,
    required this.hitDurationsListenable,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
  }) : super(
    repaint: Listenable.merge([
      smoothMsListenable,
      userPitchListenable,
      hitDurationsListenable,
    ]),
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty || maxPitch <= minPitch) return;

    final currentMs = smoothMsListenable.value.toInt();
    final userPitchHz = userPitchListenable.value;
    final hitDurations = hitDurationsListenable.value;

    final pitchHeight = size.height / (maxPitch - minPitch + 2);
    final playheadX = size.width * 0.3;

    if (userPitchHz != _cachedPitchHz) {
      _cachedPitchHz = userPitchHz;
      _cachedUserMidi = userPitchHz > 50
          ? 69 + 12 * (log(userPitchHz / 440) / ln2)
          : 0;
    }

    final visibleStartMs = currentMs - (playheadX / pxPerms);
    final visibleEndMs = currentMs + ((size.width - playheadX) / pxPerms);

    int lo = 0, hi = notes.length - 1, first = notes.length;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (notes[mid].startMs + notes[mid].durationMs >= visibleStartMs) {
        first = mid;
        hi = mid - 1;
      } else {
        lo = mid + 1;
      }
    }

    for (int i = first; i < notes.length; i++) {
      final note = notes[i];
      if (note.startMs > visibleEndMs) break;

      final rawStartX = playheadX + (note.startMs - currentMs) * pxPerms;
      final rawEndX = rawStartX + note.durationMs * pxPerms;

      final double startX = rawStartX + _strokeRadius;
      double endX = rawEndX - _strokeRadius;
      if (endX < startX) endX = startX + 0.1;

      if (endX < -_strokeRadius || startX > size.width + _strokeRadius) continue;

      final y = size.height - (note.midiPitch - minPitch + 1) * pitchHeight;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), _paintUpcoming);

      final hitMs = hitDurations[note.startMs] ?? 0.0;
      if (hitMs > 0) {
        final playedMs = (currentMs - note.startMs).clamp(0, note.durationMs);
        final hitStart = playedMs.toDouble() - hitMs;
        final hitStartX = ((rawStartX + hitStart * pxPerms) + _strokeRadius).clamp(startX, endX);
        double hitEndX = (rawStartX + playedMs * pxPerms) - _strokeRadius;
        if (hitEndX < hitStartX) hitEndX = hitStartX + 0.1;
        if (hitEndX > endX) hitEndX = endX;

        if (hitEndX > -_strokeRadius && hitStartX < size.width + _strokeRadius) {
          canvas.drawLine(Offset(hitStartX, y), Offset(hitEndX, y), _paintSung);
        }
      }
    }

    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      _playheadPaint,
    );

    if (_cachedUserMidi > 0) {
      final userY =
      (size.height - (_cachedUserMidi - minPitch + 1) * pitchHeight)
          .clamp(0.0, size.height);
      canvas.drawCircle(Offset(playheadX, userY), 8, _paintUserDot);
    }
  }

  @override
  bool shouldRepaint(covariant PianoGridPainter old) => false;
}