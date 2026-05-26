import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/practices/midi_note_practices.dart';

class AnimatedPiano extends StatefulWidget {
  final List<MidiNotePractices> notes;
  final int currentMs;
  final double userPitchHz;
  final Map<int, double> hitDuration;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;
  final bool isPlaying;

  const AnimatedPiano({
    super.key,
    required this.notes,
    required this.currentMs,
    required this.userPitchHz,
    required this.hitDuration,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
    required this.isPlaying,
  });

  @override
  State<AnimatedPiano> createState() => _AnimatedPianoState();
}

class _AnimatedPianoState extends State<AnimatedPiano>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _smoothMsNotifier = ValueNotifier<double>(0);

  late List<Paint> _notePaints;

  int _baseMs = 0;
  double _pauseMs = 0;
  Duration _baseElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _baseMs = widget.currentMs;
    _notePaints = PianoPainter.buildNotePaints(widget.notes);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(() {
      final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
      final ms = _baseMs + (elapsed - _baseElapsed).inMilliseconds;
      _smoothMsNotifier.value = ms.toDouble();
    });

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedPiano old) {
    super.didUpdateWidget(old);

    // Chỉ tính lại notePaints khi notes thay đổi
    if (old.notes != widget.notes) {
      _notePaints = PianoPainter.buildNotePaints(widget.notes);
    }

    if (old.currentMs != widget.currentMs) {
      _baseMs = widget.currentMs;
      _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
    }

    if (old.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _baseMs = _pauseMs.toInt();
        _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
        _controller.forward();
      } else {
        _pauseMs = _smoothMsNotifier.value;
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
      painter: PianoPainter(
        notes: widget.notes,
        smoothMsListenable: _smoothMsNotifier,
        userPitchHz: widget.userPitchHz,
        hitDurations: widget.hitDuration,
        minPitch: widget.minPitch,
        maxPitch: widget.maxPitch,
        pxPerms: widget.pxPerms,
        notePaints: _notePaints,
      ),
    );
  }
}

class PianoPainter extends CustomPainter {
  final List<MidiNotePractices> notes;
  final ValueNotifier<double> smoothMsListenable;
  final double userPitchHz;
  final Map<int, double> hitDurations;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;
  final List<Paint> notePaints;

  // Tính userMidi 1 lần khi userPitchHz thay đổi
  final double _userMidi;

  PianoPainter({
    required this.notes,
    required this.smoothMsListenable,
    required this.userPitchHz,
    required this.hitDurations,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
    required this.notePaints,
  })  : _userMidi = userPitchHz > 50
      ? 69 + 12 * (log(userPitchHz / 440) / ln2)
      : -1,
        super(repaint: smoothMsListenable);

  // Static: tính 1 lần từ State, không tính lại mỗi frame
  static List<Paint> buildNotePaints(List<MidiNotePractices> notes) {
    final paints = List<Paint>.filled(notes.length, _paintUpcomingLow);
    int groupIndex = 0;
    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final prevNote = i > 0 ? notes[i - 1] : null;
      final isStartOfGroup = prevNote == null ||
          (note.startMs - (prevNote.startMs + prevNote.durationMs)) > 200;
      if (isStartOfGroup && i > 0) groupIndex++;
      paints[i] = groupIndex.isEven ? _paintUpcomingLow : _paintUpcomingHigh;
    }
    return paints;
  }

  static final _paintUpcomingHigh = Paint()
    ..color = AppColors.highNote
    ..strokeWidth = 34;
  static final _paintUpcomingLow = Paint()
    ..color = AppColors.lowNote
    ..strokeWidth = 34;
  static final _hitNote = Paint()
    ..color = AppColors.noteHit
    ..strokeWidth = 34;
  static final _userDot = Paint()..color = AppColors.userDot;

  static const _noteRadius = Radius.circular(5.0);
  static const _noteHeightRatio = 0.7;
  static const _playheadRatio = 0.3;
  static const _userDotRadius = 10.0;
  static const _minNoteWidth = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty || maxPitch <= minPitch) return;

    final currentMs = smoothMsListenable.value;
    final pitchCount = maxPitch - minPitch + 2;
    final pitchHeight = size.height / pitchCount;
    final noteHeight = pitchHeight * _noteHeightRatio;
    final playheadX = size.width * _playheadRatio;

    _drawNotes(canvas, size, currentMs, pitchHeight, noteHeight, playheadX);
    _drawUserDot(canvas, size, pitchHeight, noteHeight, playheadX);
  }

  void _drawNotes(
      Canvas canvas,
      Size size,
      double currentMs,
      double pitchHeight,
      double noteHeight,
      double playheadX,
      ) {

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final startX = playheadX + (note.startMs - currentMs) * pxPerms;
      final endX = startX + note.durationMs * pxPerms;

      // Skip nếu ngoài màn hình
      if (endX < 0 || startX > size.width) continue;

      final y = size.height - (note.midiPitch - minPitch + 1) * pitchHeight;
      final top = y - noteHeight / 2;
      final safeEndX = endX > startX ? endX : startX + _minNoteWidth;

      // Vẽ note
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          startX, top, safeEndX, top + noteHeight,
          topLeft: _noteRadius,
          topRight: _noteRadius,
          bottomLeft: _noteRadius,
          bottomRight: _noteRadius,
        ),
        notePaints[i],
      );

      // Vẽ hit overlay
      final hitMs = hitDurations[note.startMs] ?? 0.0;
      if (hitMs > 0) {
        final playedMs = (currentMs - note.startMs).clamp(0, note.durationMs);
        final hitLen = min(hitMs, playedMs.toDouble());
        final hitEndX = (startX + hitLen * pxPerms)
            .clamp(startX + _minNoteWidth, safeEndX);

        if (hitEndX > 0 && startX < size.width) {
          canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              startX, top, hitEndX, top + noteHeight,
              topLeft: _noteRadius,
              topRight: _noteRadius,
              bottomLeft: _noteRadius,
              bottomRight: _noteRadius,
            ),
            _hitNote,
          );
        }
      }
    }
  }

  void _drawUserDot(
      Canvas canvas,
      Size size,
      double pitchHeight,
      double noteHeight,
      double playheadX,
      ) {
    final double userY;
    if (_userMidi <= 0) {
      userY = size.height / 2;
    } else {
      userY = (size.height - (_userMidi - minPitch + 1) * pitchHeight)
          .clamp(0.0, size.height);
    }
    canvas.drawCircle(Offset(playheadX, userY), _userDotRadius, _userDot);

  }

  @override
  bool shouldRepaint(covariant PianoPainter old) =>
      old.userPitchHz != userPitchHz ||
          old.hitDurations != hitDurations ||
          old.minPitch != minPitch ||
          old.maxPitch != maxPitch ||
          old.pxPerms != pxPerms ||
          old.notePaints != notePaints;
}