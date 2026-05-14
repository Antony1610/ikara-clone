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

  int _baseMs = 0;
  Duration _baseElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _baseMs = widget.currentMs;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(() {
      final elapsed =
          _controller.lastElapsedDuration ?? Duration.zero;

      final ms = _baseMs + (elapsed - _baseElapsed).inMilliseconds;

      _smoothMsNotifier.value = ms.toDouble();
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPianoGrid old) {
    super.didUpdateWidget(old);

    if (old.currentMs != widget.currentMs) {
      _baseMs = widget.currentMs;
      _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
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
    _controller.dispose();
    _smoothMsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PianoGridPainter(
        notes: widget.notes,
        smoothMsListenable: _smoothMsNotifier,
        userPitchHz: widget.userPitchHz,
        hitDurations: widget.hitDurations,
        minPitch: widget.minPitch,
        maxPitch: widget.maxPitch,
        pxPerms: widget.pxPerms,
      ),
    );
  }
}


class PianoGridPainter extends CustomPainter {
  final List<MidiNote> notes;
  final ValueNotifier<double> smoothMsListenable;
  final double userPitchHz;
  final Map<int, double> hitDurations;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;

  static final _playheadPaint = Paint()
    ..color = AppColors.buttonInsideLesson
    ..strokeWidth = 2;

  static final _paintUpcoming = Paint()
    ..color = Colors.white24
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  static final _paintSung = Paint()
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  static final _paintUserDot = Paint()..color = Colors.white;

  PianoGridPainter({
    required this.notes,
    required this.smoothMsListenable,
    required this.userPitchHz,
    required this.hitDurations,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
  }) : super(repaint: smoothMsListenable);

  @override
  void paint(Canvas canvas, Size size) {
    final currentMs = smoothMsListenable.value.toInt();
    if (notes.isEmpty || maxPitch <= minPitch) return;

    final pitchHeight = size.height / (maxPitch - minPitch + 2);
    final playheadX = size.width * 0.3;

    double userMidi = 0;
    if (userPitchHz > 50) {
      userMidi = 69 + 12 * (log(userPitchHz / 440) / ln2);
    }


    final double strokeRadius = _paintUpcoming.strokeWidth / 2;


    _paintSung.color = AppColors.buttonInsideLesson;

    for (final note in notes) {
      // 1. Tính tọa độ thô (dựa trên thời gian thực tế)
      final rawStartX = playheadX + (note.startMs - currentMs) * pxPerms;
      final rawEndX = rawStartX + note.durationMs * pxPerms;

      // 2. Thu ngắn đoạn thẳng lại để bù trừ cho phần lồi ra của StrokeCap.round
      double startX = rawStartX + strokeRadius;
      double endX = rawEndX - strokeRadius;

      // Xử lý nốt quá ngắn (thời lượng ngắn khiến endX bị lùi sâu hơn startX)
      if (endX < startX) {
        endX = startX + 0.1; // Vẽ thành một chấm tròn
      }

      // 3. Bỏ qua nếu note hoàn toàn nằm ngoài màn hình (tính cả phần bo tròn)
      if (endX < -strokeRadius || startX > size.width + strokeRadius) continue;

      final y = size.height - (note.midiPitch - minPitch + 1) * pitchHeight;

      // Vẽ upcoming note
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        _paintUpcoming,
      );

      // Hit Progress
      final hitMs = hitDurations[note.startMs] ?? 0.0;

      if (hitMs > 0) {
        final playedMs = (currentMs - note.startMs).clamp(0, note.durationMs);
        final hitLen = min(hitMs, playedMs.toDouble());

        // Tính tọa độ kết thúc thô của phần đã hát
        final rawHitEndX = rawStartX + hitLen * pxPerms;

        // Tọa độ bắt đầu của hit progress giống với tọa độ background note
        double hitStartX = startX;

        // Tọa độ kết thúc cũng cần trừ đi strokeRadius để khớp với StrokeCap
        double hitEndX = rawHitEndX - strokeRadius;

        // Đảm bảo phần hát không bị lùi ngược lại khi hitLen quá nhỏ
        if (hitEndX < hitStartX) {
          hitEndX = hitStartX + 0.1;
        }

        // Đảm bảo phần hát không vượt quá điểm kết thúc của toàn bộ note
        if (hitEndX > endX) {
          hitEndX = endX;
        }

        if (hitEndX > -strokeRadius && hitStartX < size.width + strokeRadius) {
          canvas.drawLine(
            Offset(hitStartX, y),
            Offset(hitEndX, y),
            _paintSung,
          );
        }
      }
    }

    // -------------------------
    // PLAYHEAD
    // -------------------------
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      _playheadPaint,
    );

    // -------------------------
    // USER DOT
    // -------------------------
    if (userMidi > 0) {
      final userY = (size.height - (userMidi - minPitch + 1) * pitchHeight)
          .clamp(0.0, size.height);

      canvas.drawCircle(
        Offset(playheadX, userY),
        8,
        _paintUserDot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PianoGridPainter old) =>
      old.userPitchHz != userPitchHz ||
          old.minPitch != minPitch ||
          old.maxPitch != maxPitch;
}