import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class KaraokeAudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final _pitchController = StreamController<double>.broadcast();
  final _volumeController = StreamController<int>.broadcast();
  final _playbackProgressController = StreamController<int>.broadcast();
  late StreamController<Uint8List> _audioController;
  StreamSubscription? _subscription;
  Stream<double> get pitchStream => _pitchController.stream;
  Stream<int> get volumeStream => _volumeController.stream;
  Stream<int> get playbackProgressStream => _playbackProgressController.stream;
  bool _isRecording = false;

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> start(String audioUrl) async {
    if (_isRecording) await stop();
    final granted = await _requestMicPermission();

    if (!granted) {
      throw Exception("Microphone permission denied");
    }
    await _player.openPlayer();
    await _player.setSubscriptionDuration(const Duration(milliseconds: 50));
    _player.onProgress!.listen((event){
      _playbackProgressController.add(event.position.inMilliseconds);
    });
    await _player.startPlayer(
      codec: Codec.mp3,
      fromURI: audioUrl
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

    final samples = _pcmToSamples(buffer);

    if (samples.length < 1024) return;

    final volume = _calculateVolume(samples);
    _volumeController.add(volume);

    // 🔥 Detect pitch
    final pitch = _detectPitch(samples);

    if (pitch > 0) {
      _pitchController.add(pitch);
    }
  }

  List<int> _pcmToSamples(Uint8List bytes) {
    final samples = <int>[];
    final byteData = ByteData.sublistView(bytes);
    for (int i = 0; i < bytes.length; i += 4) {
      if (i+3 >= bytes.length) break;
      int leftChannel = byteData.getInt16(i, Endian.little);
      int rightChannel = byteData.getInt16(i+2, Endian.little);
      int mixed = (leftChannel + rightChannel) ~/ 2;
      samples.add(mixed);
    }

    return samples;
  }

  int _calculateVolume(List<int> samples) {
    if (samples.isEmpty) return 0;

    double sum = 0;

    for (final s in samples) {
      sum += s.abs();
    }

    return (sum / samples.length).round();
  }

  double _detectPitch(List<int> samples) {
    int crossings = 0;

    for (int i = 1; i < samples.length; i++) {
      if ((samples[i - 1] < 0 && samples[i] >= 0) ||
          (samples[i - 1] > 0 && samples[i] <= 0)) {
        crossings++;
      }
    }

    double freq = (crossings * 44100) / (2 * samples.length);

    if (freq < 50 || freq > 1000) return 0;

    return freq;
  }
  Future<void> pause() async {
    if (_player.isPlaying) {
      await _player.pausePlayer();
    }
  }

  Future<void> resume() async {
    if (_player.isPaused) {
      await _player.resumePlayer();
    }
  }

  Future<void> dispose() async {
    await stop();
    _pitchController.close();
    _volumeController.close();
    _playbackProgressController.close();
  }
}
