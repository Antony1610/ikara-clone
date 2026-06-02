import 'dart:async';
import 'dart:typed_data';

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
  final _completeController = StreamController<void>.broadcast();
  Stream<void> get onCompleteStream => _completeController.stream;
  final List<int> _sampleAccumulator = [];
  static const int _requiredSamples = 1024;
  static const int _requiredBytes = _requiredSamples * 2;
  bool _isRecording = false;
  bool _isProcessing = false;

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> start(String audioUrl) async {
    if (_isRecording) await stop();

    await _pitchDetector.initialize(
      sampleRate: 44100.0,
      bufferSize: 1024,
      threshold: 0.2,
    );

    final granted = await _requestMicPermission();
    if (!granted) throw Exception("Microphone permission denied");

    await _player.openPlayer();
    await _player.setSubscriptionDuration(const Duration(milliseconds: 50));
    _player.onProgress?.listen((event) {
      _playbackProgressController.add(event.position.inMilliseconds);
    });

    await _player.startPlayer(
      codec: Codec.mp3,
      fromURI: audioUrl,
      whenFinished:  _onPlaybackFinished,
    );

    await _recorder.openRecorder();
    _audioController = StreamController<Uint8List>();
    _subscription = _audioController.stream.listen(_onAudioData);
    _isRecording = true;

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 2,
      toStream: _audioController.sink,
    );
  }

  void _onAudioData(Uint8List buffer) {
    if (!_isRecording || _isProcessing) return;
    final monoBuffer = _stereoToMono(buffer);

    _sampleAccumulator.addAll(monoBuffer);
    while (_sampleAccumulator.length >= _requiredBytes) {
      final frame = Uint8List.fromList(
        _sampleAccumulator.sublist(0, _requiredBytes),
      );
      _sampleAccumulator.removeRange(0, _requiredBytes);

      _isProcessing = true;
      _pitchDetector
          .getPitch(frame)
          .then((pitch) {
            if (pitch > 0 && !_pitchController.isClosed) {
              _pitchController.add(pitch);
            }
          })
          .whenComplete(() => _isProcessing = false);

      break;
    }
  }

  void _onPlaybackFinished() {
    _isRecording = false;
    if (!_completeController.isClosed) {
      _completeController.add(null);
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
    _completeController.close();
  }

  Uint8List _stereoToMono(Uint8List stereoBytes) {
    final aligned = Uint8List.fromList(stereoBytes);
    final stereoInt16 = aligned.buffer.asInt16List();
    final monoLength = stereoInt16.length ~/ 2;
    final monoInt16 = Int16List(monoLength);
    for (int i = 0; i < stereoInt16.length - 1; i += 2) {
      final left = stereoInt16[i];
      final right = stereoInt16[i + 1];
      monoInt16[i ~/ 2] = (left + right) >> 1;
    }
    return monoInt16.buffer.asUint8List();
  }
}
