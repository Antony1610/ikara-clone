import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../constants/constants.dart';

class SeekBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(Duration) onSeek;

  const SeekBar({
    super.key,
    required this.controller,
    required this.onSeek,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    final duration = value.duration.inMilliseconds.toDouble();
    final position = value.position.inMilliseconds.toDouble();

    final progress = _isDragging
        ? _dragValue
        : (duration == 0 ? 0.0 : position / duration);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // ================= START DRAG =================
      onHorizontalDragStart: (_) {
        setState(() {
          _isDragging = true;
          _dragValue = progress;
        });
      },

      // ================= DRAG UPDATE =================
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localX = box.globalToLocal(details.globalPosition).dx;

        final percent = (localX / box.size.width).clamp(0.0, 1.0);

        setState(() {
          _dragValue = percent;
        });
      },

      // ================= END DRAG =================
      onHorizontalDragEnd: (_) {
        final seekTo = Duration(
          milliseconds: (duration * _dragValue).toInt(),
        );

        widget.onSeek(seekTo);

        setState(() {
          _isDragging = false;
        });
      },

      child: SizedBox(
        height: 20,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // background
                Container(
                  height: 4,
                  width: width,
                  color: Colors.white24,
                ),

                // played
                Container(
                  height: 4,
                  width: width * progress,
                  color: AppColors.progressColor,
                ),

                // thumb
                Positioned(
                  left: (width * progress) - 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.progressColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}