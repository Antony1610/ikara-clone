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
  final _userPitchNotifier = ValueNotifier<double>(0);
  final _hitDurationNotifier = ValueNotifier<Map<int, double>>({});

  late List<Paint> _notePaints;
  int _baseMs = 0;
  Duration _baseElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _baseMs = widget.currentMs;
    _notePaints = PianoPainter.buildNotePaints(widget.notes);
    _userPitchNotifier.value = widget.userPitchHz;
    _hitDurationNotifier.value = widget.hitDuration;

    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 999))
          ..addListener(() {
            final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
            _smoothMsNotifier.value =
                _baseMs + (elapsed - _baseElapsed).inMilliseconds.toDouble();
          });

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPiano old) {
    super.didUpdateWidget(old);

    if (old.notes != widget.notes) {
      _notePaints = PianoPainter.buildNotePaints(widget.notes);
    }

    if (old.currentMs != widget.currentMs) {
      _baseMs = widget.currentMs;
      _baseElapsed = _controller.lastElapsedDuration ?? Duration.zero;
    }

    if (old.userPitchHz != widget.userPitchHz) {
      _userPitchNotifier.value = widget.userPitchHz;
    }

    if (old.hitDuration != widget.hitDuration) {
      _hitDurationNotifier.value = widget.hitDuration;
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
    _userPitchNotifier.dispose();
    _hitDurationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: PianoPainter(
          notes: widget.notes,
          smoothMsListenable: _smoothMsNotifier,
          userPitchListenable: _userPitchNotifier,
          hitDurationsListenable: _hitDurationNotifier,
          minPitch: widget.minPitch,
          maxPitch: widget.maxPitch,
          pxPerms: widget.pxPerms,
          notePaints: _notePaints,
        ),
      ),
    );
  }
}

class _MergedListenable extends Listenable {
  final List<Listenable> _listenables;
  _MergedListenable(this._listenables);

  @override
  void addListener(VoidCallback listener) {
    for (final l in _listenables) {
      l.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (final l in _listenables) {
      l.removeListener(listener);
    }
  }
}

class PianoPainter extends CustomPainter {
  final List<MidiNotePractices> notes;
  final ValueNotifier<double> smoothMsListenable;
  final ValueNotifier<double> userPitchListenable;
  final ValueNotifier<Map<int, double>> hitDurationsListenable;
  final int minPitch;
  final int maxPitch;
  final double pxPerms;
  final List<Paint> notePaints;

  PianoPainter({
    required this.notes,
    required this.smoothMsListenable,
    required this.userPitchListenable,
    required this.hitDurationsListenable,
    required this.minPitch,
    required this.maxPitch,
    required this.pxPerms,
    required this.notePaints,
  }) : super(
         repaint: _MergedListenable([
           smoothMsListenable,
           userPitchListenable,
           hitDurationsListenable,
         ]),
       );

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

  static List<Paint> buildNotePaints(List<MidiNotePractices> notes) {
    final paints = List<Paint>.filled(
      notes.length,
      _paintUpcomingLow,
      growable: false,
    );
    int groupIndex = 0;
    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final prev = i > 0 ? notes[i - 1] : null;
      final isNewGroup =
          prev == null ||
          (note.startMs - (prev.startMs + prev.durationMs)) > 200;
      if (isNewGroup && i > 0) groupIndex++;
      paints[i] = groupIndex.isEven ? _paintUpcomingLow : _paintUpcomingHigh;
    }
    return paints;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty || maxPitch <= minPitch) return;

    final currentMs = smoothMsListenable.value;
    final userPitchHz = userPitchListenable.value;
    final hitDurations = hitDurationsListenable.value;

    final pitchCount = maxPitch - minPitch + 2;
    final pitchHeight = size.height / pitchCount;
    final noteHeight = pitchHeight * _noteHeightRatio;
    final playheadX = size.width * _playheadRatio;

    _drawNotes(
      canvas,
      size,
      currentMs,
      userPitchHz,
      hitDurations,
      pitchHeight,
      noteHeight,
      playheadX,
    );
    _drawUserDot(canvas, size, userPitchHz, pitchHeight, playheadX);
  }

  void _drawNotes(
    Canvas canvas,
    Size size,
    double currentMs,
    double userPitchHz,
    Map<int, double> hitDurations,
    double pitchHeight,
    double noteHeight,
    double playheadX,
  ) {
    final userMidi = userPitchHz > 50
        ? 69.0 + 12.0 * (log(userPitchHz / 440.0) / ln2)
        : -1.0;

    final visibleStartMs = currentMs - (playheadX / pxPerms);
    final visibleEndMs = currentMs + ((size.width - playheadX) / pxPerms);

    // Binary search note đầu tiên visible
    int lo = 0, hi = notes.length - 1, firstVisible = notes.length;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final n = notes[mid];
      if (n.startMs + n.durationMs >= visibleStartMs) {
        firstVisible = mid;
        hi = mid - 1;
      } else {
        lo = mid + 1;
      }
    }

    for (int i = firstVisible; i < notes.length; i++) {
      final note = notes[i];
      if (note.startMs > visibleEndMs) break;

      final startX = playheadX + (note.startMs - currentMs) * pxPerms;
      final endX = startX + note.durationMs * pxPerms;
      final safeEndX = endX > startX + _minNoteWidth
          ? endX
          : startX + _minNoteWidth;

      final y = size.height - (note.midiPitch - minPitch + 1) * pitchHeight;
      final top = y - noteHeight / 2;

      // Vẽ note nền
      canvas.drawRRect(
        RRect.fromLTRBR(startX, top, safeEndX, top + noteHeight, _noteRadius),
        notePaints[i],
      );

      // Vẽ hit overlay
      final isHit =
          userMidi > 0 &&
          currentMs >= note.startMs &&
          currentMs <= note.startMs + note.durationMs &&
          (note.midiPitch - userMidi).abs() <= 0.4;
      if (isHit) {
        final hitEndX = playheadX.clamp(startX + _minNoteWidth, safeEndX);
        canvas.drawRRect(
          RRect.fromLTRBR(startX, top, hitEndX, top + noteHeight, _noteRadius),
          _hitNote,
        );
      }
    }
  }

  void _drawUserDot(
    Canvas canvas,
    Size size,
    double userPitchHz,
    double pitchHeight,
    double playheadX,
  ) {
    final userMidi = userPitchHz > 50
        ? 69.0 + 12.0 * (log(userPitchHz / 440.0) / ln2)
        : -1.0;

    final userY = userMidi <= 0
        ? size.height / 2
        : (size.height - (userMidi - minPitch + 1) * pitchHeight).clamp(
            0.0,
            size.height,
          );

    canvas.drawCircle(Offset(playheadX, userY), _userDotRadius, _userDot);
  }

  @override
  bool shouldRepaint(covariant PianoPainter old) =>
      old.minPitch != minPitch ||
      old.maxPitch != maxPitch ||
      old.pxPerms != pxPerms ||
      old.notePaints != notePaints ||
      old.notes != notes;
}
