import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../data/model/rhythms/note.dart';

class RhythmPainter extends CustomPainter {
  final List<Note> notes;
  final int currentTime;
  final double hitZoneX;
  final double pixelsPerMs;

  RhythmPainter({
    required this.notes,
    required this.currentTime,
    required this.hitZoneX,
    required this.pixelsPerMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final notePaint = Paint()..color = Colors.white;
    final hitLinePaint = Paint()..color = AppColors.progressColor;

    canvas.drawRect(Rect.fromLTWH(hitZoneX, 0, 3, size.height), hitLinePaint);

    for (final note in notes) {
      final x = hitZoneX + (note.timeMs - currentTime) * pixelsPerMs;

      if (x < -50 || x > size.width + 50) continue;

      notePaint.color = note.type == NoteType.beat
          ? AppColors.noteColor
          : Colors.white38;

      canvas.drawCircle(Offset(x, size.height / 2), 6, notePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RhythmPainter oldDelegate) {
    return oldDelegate.currentTime != currentTime;
  }
}
