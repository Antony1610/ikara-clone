import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ikara_clone/data/services/pitch_detector_service.dart';
import 'package:permission_handler/permission_handler.dart';

class KaraokeAudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  final _pitchController = StreamController<double>.broadcast();
  final _playbackProgressController = StreamController<int>.broadcast();

  final _pitchDetector = PitchDetectorService();
  late StreamController<Uint8List> _audioController;
  StreamSubscription? _subscription;

  Stream<double> get pitchStream => _pitchController.stream;
  Stream<int> get playbackProgressStream => _playbackProgressController.stream;

  final List<int> _sampleAccumulator = [];
  static const int _requiredSamples = 1024;
  static const int _requiredBytes = _requiredSamples * 2;
  bool _isRecording = false;
  bool _processing = false;

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> start(String audioUrl) async {
    if (_isRecording) await stop();

    await _pitchDetector.initialize(
      sampleRate: 44100.0,
      bufferSize: 1024,
      threshold: 0.15,
    );

    final granted = await _requestMicPermission();
    if (!granted) throw Exception("Microphone permission denied");

    await _player.openPlayer();
    await _player.setSubscriptionDuration(const Duration(milliseconds: 40));
    _player.onProgress?.listen((event) {
      _playbackProgressController.add(event.position.inMilliseconds);
    });
    await _player.startPlayer(codec: Codec.mp3, fromURI: audioUrl);

    await _recorder.openRecorder();
    _audioController = StreamController<Uint8List>();
    _subscription = _audioController.stream.listen(_onAudioData);
    _isRecording = true;

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      toStream: _audioController.sink,
    );
  }

  void _onAudioData(Uint8List buffer) {
    if (!_isRecording) return;

    _sampleAccumulator.addAll(buffer);

    debugPrint(
      '[Audio] Accumulator: ${_sampleAccumulator.length}/$_requiredSamples samples',
    );


    while (_sampleAccumulator.length >= _requiredSamples) {
      if (_processing) {
        break;
      }

      final samples = Uint8List.fromList(_sampleAccumulator.sublist(0, _requiredBytes));
      _sampleAccumulator.removeRange(0, _requiredSamples);

      double avg = samples.map((e) => e.abs()).reduce((a, b) => a + b) / samples.length;
      debugPrint("Amplitude: $avg");
      _processing = true;
      _pitchDetector
          .getPitch(samples)
          .then((pitch) {
            debugPrint('[Pitch] Kết quả: ${pitch.toStringAsFixed(2)} Hz');
            if (pitch > 60) {
              _pitchController.add(double.parse(pitch.toStringAsFixed(1)));
            }
          })
          .whenComplete(() => _processing = false);
    }
  }

  Future<void> stop() async {
    _isRecording = false;
    _sampleAccumulator.clear();

    await _pitchDetector.dispose();
    if (_recorder.isRecording) await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    if (_player.isPlaying || _player.isPaused) await _player.stopPlayer();
    await _player.closePlayer();

    await _subscription?.cancel();
    await _audioController.close();
  }

  Future<void> pause() async {
    if (_player.isPlaying) await _player.pausePlayer();
  }

  Future<void> resume() async {
    if (_player.isPaused) await _player.resumePlayer();
  }

  Future<void> dispose() async {
    await stop();
    _pitchController.close();
    _playbackProgressController.close();
  }
}
