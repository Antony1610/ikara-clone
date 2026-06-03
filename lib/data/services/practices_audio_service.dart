import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ikara_clone/data/services/pitch_detector_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PracticesAudioService {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final PitchDetectorService _pitchDetector = PitchDetectorService();

  final _pitchController = StreamController<double>.broadcast();
  Stream<double> get pitchStream => _pitchController.stream;

  final _completeController = StreamController<void>.broadcast();
  Stream<void> get onCompleteStream => _completeController.stream;

  Stream<Duration> get positionStream => _positionBroadcast ?? Stream.empty();

  StreamController<Uint8List>? _audioController;
  StreamSubscription? _audioSubscription;
  Stream<Duration>? _positionBroadcast;

  static const int _requiredSamples = 1024;
  static const int _requiredBytes = _requiredSamples * 2;
  final Uint8List _frameBuffer = Uint8List(_requiredBytes);
  int _bufferOffset = 0;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _loadedFilePath;

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String> _loadAssetToFile(String fileName) async {
    final assetPath = 'assets/assets_data/Practices/$fileName';
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final file = File('${Directory.systemTemp.path}/$fileName');
    if (!file.existsSync() || await file.length() != bytes.length) {
      await file.writeAsBytes(bytes);
    }
    return file.path;
  }

  Future<void> load(String fileName) async {
    _loadedFilePath = await _loadAssetToFile(fileName);
    await Future.wait([
      _pitchDetector.initialize(
        sampleRate: 44100,
        bufferSize: _requiredSamples,
        threshold: 0.2,
      ),
      _requestMicPermission().then((granted) {
        if (!granted) throw Exception('Microphone permission denied');
      }),
      _player.openPlayer(),
      _recorder.openRecorder(),
    ]);
    await _player.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  Future<void> start() async {
    assert(_loadedFilePath != null, 'Gọi load() trước khi start()');

    _audioController = StreamController<Uint8List>();
    _audioSubscription = _audioController!.stream.listen(_onAudioData);

    _positionBroadcast = _player.onProgress!
        .map((e) => e.position)
        .asBroadcastStream();

    await Future.wait([
      _player.startPlayer(
        fromURI: _loadedFilePath!,
        codec: Codec.mp3,
        whenFinished: _onPlaybackFinished,
      ),
      _recorder.startRecorder(
        codec: Codec.pcm16,
        sampleRate: 44100,
        numChannels: 2,
        toStream: _audioController!.sink,
      ),
    ]);

    _isRecording = true;
  }

  Future<void> pause() async {
    if (_player.isPlaying) await _player.pausePlayer();
  }

  Future<void> resume() async {
    if (_player.isPaused) await _player.resumePlayer();
  }

  Future<void> stop() async {
    _isRecording = false;
    _isProcessing = false;
    await _pitchDetector.dispose();

    if (_recorder.isRecording || _recorder.isPaused) {
      await _recorder.stopRecorder();
    }
    await _recorder.closeRecorder();

    await _audioSubscription?.cancel();
    _audioSubscription = null;
    if (_audioController != null && !_audioController!.isClosed) {
      await _audioController!.close();
      _audioController = null;
    }

    if (_player.isPlaying || _player.isPaused) {
      await _player.stopPlayer();
    }
    await _player.closePlayer();
  }

  Future<void> dispose() async {
    await stop();
    if (!_pitchController.isClosed) await _pitchController.close();
    if (!_completeController.isClosed) await _completeController.close();
  }

  void _onPlaybackFinished() {
    _isRecording = false;
    if (!_completeController.isClosed) {
      _completeController.add(null);
    }
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

  void _onAudioData(Uint8List buffer) {
    if (!_isRecording || _isProcessing) return;
    if (_player.isPaused) return;
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
}
