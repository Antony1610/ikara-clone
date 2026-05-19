import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikara_clone/presentation/performance_detail/bloc/performance_detail_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:ikara_clone/constants/constants.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  /// Gọi sau khi controller khởi tạo xong, truyền ra hàm pause để dùng bên ngoài
  final void Function(VoidCallback pause)? onControllerReady;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.onControllerReady,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  Timer? _hideControlsTimer;

  bool _showControls = true;

  final ValueNotifier<Duration> _positionNotifier =
  ValueNotifier(Duration.zero);

  Duration _lastUpdate = Duration.zero;

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();

    if (!_controller.value.isPlaying) return;

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showControls = false;
      });
    });
  }

  void _showControlsTemporarily() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });

    _startHideControlsTimer();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _controller.addListener(_onVideoUpdate);

    _controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {});

      _controller.play();
      _startHideControlsTimer();

      context.read<PerformanceDetailBloc>().add(
        VideoPlayPauseToggled(),
      );

      // Truyền hàm pause ra ngoài sau khi controller sẵn sàng
      widget.onControllerReady?.call(() {
        if (_controller.value.isInitialized) {
          _controller.pause();
          _hideControlsTimer?.cancel();
          if (mounted) {
            setState(() => _showControls = true);
          }
        }
      });
    });
  }

  void _onVideoUpdate() {
    if (!mounted) return;

    final current = _controller.value.position;

    if ((current - _lastUpdate).inMilliseconds < 100) return;

    _lastUpdate = current;

    _positionNotifier.value = current;

    context.read<PerformanceDetailBloc>().add(
      VideoPositionChanged(current),
    );
  }

  void _togglePlayPause() {
    final bloc = context.read<PerformanceDetailBloc>();

    _showControlsTemporarily();

    if (_controller.value.isPlaying) {
      _controller.pause();
      _hideControlsTimer?.cancel();

      setState(() {
        _showControls = true;
      });
    } else {
      _controller.play();
      _startHideControlsTimer();
    }

    bloc.add(VideoPlayPauseToggled());
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxWidth * (9 / 16); // 16:9 placeholder
          return Container(
            width: double.infinity,
            height: height,
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.progressColor),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _showControlsTemporarily,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth / _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),

                    Positioned.fill(
                      child: Container(color: Colors.transparent),
                    ),

                    if (_showControls)
                      Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 50,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                    if (_showControls)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: ValueListenableBuilder<Duration>(
                            valueListenable: _positionNotifier,
                            builder: (_, position, __) {
                              final total = _controller.value.duration;
                              final timeText =
                                  '${_formatDuration(position)} / ${_formatDuration(total)}';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SeekBar(
                                    controller: _controller,
                                    onSeek: (pos) {
                                      _controller.seekTo(pos);
                                      _showControlsTemporarily();
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}