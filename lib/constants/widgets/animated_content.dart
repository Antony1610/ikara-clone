import 'package:flutter/material.dart';

class AnimatedContent extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const AnimatedContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, -0.3),
  });

  @override
  State<AnimatedContent> createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<AnimatedContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();

    _slide = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final Duration duration;

  const AnimatedAppBar({
    super.key,
    required this.appBar,
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedContent(
      duration: duration,
      beginOffset: const Offset(0, -0.15),
      child: appBar,
    );
  }
}
