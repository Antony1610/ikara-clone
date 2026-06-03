import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../../../constants/constants.dart';

// Lưu ý: Đảm bảo bạn đã import file chứa class AppColors vào đây
// import 'đường_dẫn_tới_file/app_colors.dart';

class IntroOverlay extends StatefulWidget {
  final String audioUrl;
  final String id;
  final VoidCallback onClose;

  const IntroOverlay({
    super.key,
    required this.audioUrl,
    required this.id,
    required this.onClose,
  });

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  StreamSubscription? _playerSubscription;
  bool _playerReady = false;
  bool _isPlaying = false;
  String? _tmpAudioPath;
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(
    Duration.zero,
  );
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _player.closePlayer();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    try {
      final assetPath = 'assets/assets_data/Practices/${widget.audioUrl}';
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      final tmp = File('${Directory.systemTemp.path}/${widget.audioUrl}');
      if (!tmp.existsSync() || await tmp.length() != bytes.length) {
        await tmp.writeAsBytes(bytes);
      }
      _tmpAudioPath = tmp.path;

      await _player.openPlayer();
      await _player.setSubscriptionDuration(const Duration(milliseconds: 200));

      _playerSubscription = _player.onProgress!.listen((e) {
        if (mounted) {
          setState(() {
            _positionNotifier.value = e.position;
            _durationNotifier.value = e.duration;
          });
        }
      });

      if (mounted) setState(() => _playerReady = true);
    } catch (e) {
      debugPrint('IntroOverlay _initPlayer error: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (!_playerReady || _tmpAudioPath == null) return;

    try {
      if (_isPlaying) {
        await _player.pausePlayer();
        setState(() => _isPlaying = false);
      } else {
        if (_player.isPaused) {
          await _player.resumePlayer();
        } else {
          await _player.startPlayer(
            fromURI: _tmpAudioPath,
            whenFinished: () {
              if (mounted) {
                setState(() {
                  _isPlaying = false;
                  _positionNotifier.value = Duration.zero;
                });
              }
            },
          );
        }
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint('IntroOverlay _togglePlay error: $e');
    }
  }

  Future<void> _closeOverlay() async {
    if (_player.isPlaying || _player.isPaused) {
      await _player.stopPlayer();
    }
    widget.onClose();
  }

  String _fmt(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: AppColors.blackText.withValues(alpha: 0.5)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nghe hướng dẫn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/practices/practices${widget.id}.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: AppColors.unSelection.withValues(
                                  alpha: 0.3,
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: AppColors.unSelection,
                                ),
                              );
                            },
                          ),
                        ),
                        ValueListenableBuilder<Duration>(
                          valueListenable: _positionNotifier,
                          builder: (_, __, ___) => _isPlaying
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    color: AppColors.blackText.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        GestureDetector(
                          onTap: _togglePlay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 48,
                            height: 48,
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: AppColors.whiteBackground,
                              size: 28,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 10,
                          child: ValueListenableBuilder<Duration>(
                            valueListenable: _positionNotifier,
                            builder: (_, pos, __) =>
                                ValueListenableBuilder<Duration>(
                                  valueListenable: _durationNotifier,
                                  builder: (_, dur, __) => Text(
                                    '${_fmt(pos)} / ${_fmt(dur)}',
                                    style: const TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 11,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: AppColors.blackText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),

                    ValueListenableBuilder<Duration>(
                      valueListenable: _positionNotifier,
                      builder: (_, pos, __) => ValueListenableBuilder<Duration>(
                        valueListenable: _durationNotifier,
                        builder: (_, dur, __) {
                          final progress = dur.inMilliseconds > 0
                              ? (pos.inMilliseconds / dur.inMilliseconds).clamp(
                                  0.0,
                                  1.0,
                                )
                              : 0.0;
                          return SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10,
                              ),
                              activeTrackColor: AppColors.buttonInsideLesson,
                              inactiveTrackColor: AppColors.unSelection
                                  .withValues(alpha: 0.3),
                              thumbColor: AppColors.buttonInsideLesson,
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: _playerReady
                                  ? (v) async {
                                      final seekPos = Duration(
                                        milliseconds: (v * dur.inMilliseconds)
                                            .round(),
                                      );
                                      _positionNotifier.value = seekPos;
                                      await _player.seekToPlayer(seekPos);
                                    }
                                  : null,
                              onChangeEnd: _playerReady
                                  ? (v) async {
                                      if (!_isPlaying) {
                                        await _player.resumePlayer();
                                        await _player.pausePlayer();
                                      }
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.introOverlayColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Quá trình khởi động này giúp bạn nhận biết giọng nói của mình đang vang lên ở đâu, cải thiện cao độ và nới lỏng dây thanh âm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _closeOverlay,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.unSelection.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.unSelection,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
