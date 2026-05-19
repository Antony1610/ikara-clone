import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class KaraokeAudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final _pitchController = StreamController<double>.broadcast();
  final _playbackProgressController = StreamController<int>.broadcast();
  late StreamController<Uint8List> _audioController;
  late final PitchDetector _pitchDetector;
  StreamSubscription? _subscription;
  final List<int> _pcmBuffer = [];
  Stream<double> get pitchStream => _pitchController.stream;
  Stream<int> get playbackProgressStream => _playbackProgressController.stream;
  bool _isRecording = false;

  static const int _sampleRate = 44100;
  static const int _bufferSize = 2048;
  static const int _requiredBytes = _bufferSize * 4; // stereo 16 bit
  KaraokeAudioService() {
    _pitchDetector = PitchDetector(
      audioSampleRate: _sampleRate.toDouble(),
      bufferSize: _bufferSize,
    );
  }

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> start(String audioUrl) async {
    if (_isRecording) await stop();
    final granted = await _requestMicPermission();
    if (!granted) throw Exception("Microphone permission denied");

    await _player.openPlayer();
    await _player.setSubscriptionDuration(const Duration(milliseconds: 50));
    _player.onProgress!.listen((event) {
      _playbackProgressController.add(event.position.inMilliseconds);
    });
    await _player.startPlayer(codec: Codec.mp3, fromURI: audioUrl);

    await _recorder.openRecorder();
    _audioController = StreamController<Uint8List>();
    _subscription = _audioController.stream.listen(_onAudioData);
    _isRecording = true;

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: _sampleRate,
      numChannels: 2,
      toStream: _audioController.sink,
    );
  }

  Future<void> stop() async {
    _isRecording = false;
    if (_recorder.isRecording) await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    if (_player.isPlaying) await _player.stopPlayer();
    await _player.closePlayer();
    await _subscription?.cancel();
    await _audioController.close();
  }

  void _onAudioData(dynamic buffer) {
    if (!_isRecording || buffer is! Uint8List) return;
    _pcmBuffer.addAll(buffer);
    while (_pcmBuffer.length >= _requiredBytes) {
      final chunk = Uint8List.fromList(_pcmBuffer.sublist(0, _requiredBytes));
      _pcmBuffer.removeRange(0, _requiredBytes);
      final mono = _stereoToMono(chunk); // Pitch detector chỉ xử lý 1 kênh
      _detectPitch(mono);
    }
  }

  Future<void> _detectPitch(Uint8List mono) async {
    if (!_isRecording) return;
    final result = await _pitchDetector.getPitchFromIntBuffer(mono);
    if (result.pitched && result.pitch >= 50 && result.pitch <= 1050) {
      _pitchController.add(result.pitch);
    }
  }

  // Stereo to Mono
  Uint8List _stereoToMono(Uint8List stereoBytes){
    final byteData = ByteData.sublistView(stereoBytes);
    final monoBytes = ByteData(_bufferSize * 2);
    for (int i = 0, j = 0; i < stereoBytes.length; i+=4, j+=2) {
      final left = byteData.getInt16(i, Endian.little);
      final right = byteData.getInt16(i+2, Endian.little);
      final mono = (left + right) ~/ 2;
      monoBytes.setInt16(j, mono, Endian.little);
    }
    return monoBytes.buffer.asUint8List();
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