import 'package:flutter/material.dart';

class LessonNode extends StatelessWidget {
  final Widget child;
  final bool isCurrent;
  final bool isPrev;
  final bool isNext;

  const LessonNode({
    super.key,
    required this.child,
    this.isCurrent = false,
    this.isPrev = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    double size;

    if (isCurrent) {
      size = 226;
    } else if (isPrev || isNext) {
      size = 172;
    } else {
      size = 100;
    }

    double opacity = isCurrent ? 1.0 : 0.6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: opacity,
        child: child,
      ),
    );
  }
}
