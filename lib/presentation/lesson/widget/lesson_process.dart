import 'package:flutter/material.dart';

class LessonProgressBorder extends StatelessWidget {
  final double progress;
  final bool quizDone;
  final Widget child;

  const LessonProgressBorder({
    super.key,
    required this.progress,
    required this.quizDone,
    required this.child,
  });

  Color get _color {
    if (quizDone && progress >= 1.0) return const Color(0xFF1D9E75);
    if (progress >= 1.0) return const Color(0xFFE24B4A);
    if (progress > 0) return const Color(0xFFEF9F27);
    return const Color(0xFF4A4A4A);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoundedProgressPainter(
        progress: progress,
        color: _color,
        radius: 18,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
      ),
    );
  }
}

class _RoundedProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;

  _RoundedProgressPainter({
    required this.progress,
    required this.color,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;

    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x22D3D1C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;

    final extract = metric.extractPath(0.0, metric.length * progress);

    canvas.drawPath(
      extract,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
