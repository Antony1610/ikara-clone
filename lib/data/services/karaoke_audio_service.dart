import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:ikara_clone/data/services/pitch_detector_service.dart';
import 'package:permission_handler/permission_handler.dart';

class KaraokeAudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  final _positionController = StreamController<Duration>.broadcast();
  final _pitchController = StreamController<double>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;
  final _pitchDetector = PitchDetectorService();
  StreamController<Uint8List>? _audioController;
  StreamSubscription? _subscription;
  StreamSubscription? _positionSub;

  Stream<double> get pitchStream => _pitchController.stream;
  final _completeController = StreamController<void>.broadcast();
  Stream<void> get onCompleteStream => _completeController.stream;
  static const int _requiredSamples = 1024;
  static const int _requiredBytes = _requiredSamples * 2;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPaused = false;
  final Uint8List _frameBuffer = Uint8List(_requiredBytes);
  int _bufferOffset = 0;
  Duration _pausePosition = Duration.zero;
  Duration _lastPositionKnow = Duration.zero;

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
    if (_player.isOpen()) await _player.closePlayer();

    await _player.openPlayer();
    await _player.setSubscriptionDuration(const Duration(milliseconds: 50));
    await _positionSub?.cancel();
    _positionSub = _player.onProgress!.listen((event) {
      _lastPositionKnow = event.position;
      if (_isPaused) return;
      if (!_positionController.isClosed) {
        _positionController.add(event.position);
      }
    });

    await _player.startPlayer(
      codec: Codec.mp3,
      fromURI: audioUrl,
      whenFinished: _onPlaybackFinished,
    );

    await _recorder.openRecorder();
    await _subscription?.cancel();
    _subscription = null;
    if (_audioController != null && !_audioController!.isClosed) {
      await _audioController!.close();
    }
    _audioController = StreamController<Uint8List>();
    _subscription = _audioController!.stream.listen(_onAudioData);
    _isRecording = true;

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 2,
      toStream: _audioController?.sink,
    );
  }

  void _onAudioData(Uint8List buffer) {
    if (!_isRecording || _isProcessing) return;
    if (_isPaused) return;
    final mono = _stereoToMono(buffer);
    int i = 0;
    while (i < mono.length) {
      final remaining = _requiredBytes - _bufferOffset;
      final toCopy = (mono.length - i < remaining)
          ? mono.length - i
          : remaining;

      _frameBuffer.setRange(_bufferOffset, _bufferOffset + toCopy, mono, i);

      _bufferOffset += toCopy;
      i += toCopy;

      if (_bufferOffset == _requiredBytes) {
        _bufferOffset = 0;

        _isProcessing = true;
        _pitchDetector
            .getPitch(_frameBuffer)
            .then((pitch) {
              if (pitch > 0 && !_pitchController.isClosed) {
                _pitchController.add(pitch);
              }
            })
            .whenComplete(() => _isProcessing = false);
      }
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
    _isProcessing = false;
    _isPaused = false;
    await _positionSub?.cancel();
    _positionSub = null;
    await _subscription?.cancel();
    _subscription = null;
    await _pitchDetector.dispose();
    if (_recorder.isRecording || _recorder.isPaused) {
      await _recorder.stopRecorder();
    }
    await _recorder.closeRecorder();
    if (_audioController != null && !_audioController!.isClosed) {
      await _audioController!.close();
      _audioController = null;
    }

    if (_player.isPlaying || _player.isPaused) await _player.stopPlayer();
    await _player.closePlayer();
  }

  Future<void> pause() async {
    if (!_isRecording || _isPaused) return;
    _isPaused = true;
    _pausePosition = _lastPositionKnow;
    await Future.wait([
      if (_player.isPlaying) _player.pausePlayer(),
      if (_recorder.isRecording) _recorder.pauseRecorder(),
    ]);
    _bufferOffset = 0;

    if (!_positionController.isClosed) {
      _positionController.add(_pausePosition);
    }
  }
  // Future<void> seekTo(Duration position) async {
  //   if (_player.isPlaying || _player.isPaused) {
  //     await _player.seekToPlayer(position);
  //   }
  // }

  Future<void> resume() async {
    await Future.wait([
      if (_player.isPaused) _player.resumePlayer(),
      if (_recorder.isPaused) _recorder.resumeRecorder(),
    ]);
    _isPaused = false;
  }

  Future<void> dispose() async {
    await stop();
    _pitchController.close();
    _positionController.close();
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
