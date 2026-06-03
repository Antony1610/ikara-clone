import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  StreamController<int>? _resultController;
  StreamController<List<Int16List>>? _pcmController;
  StreamSubscription? _streamSubscription;
  bool _isRecording = false;
  bool _isInitialized = false;

  Stream<int> get resultStream =>
      _resultController?.stream ?? const Stream.empty();

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> initRecorder() async {
    if (_isInitialized) return;

    final granted = await _requestMicPermission();
    if (!granted) throw Exception("Microphone permission denied");

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));

    _isInitialized = true;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    if (!_isInitialized) {
      await initRecorder();
    }

    if (_recorder.isRecording) return;

    await _resultController?.close();
    _resultController = StreamController<int>.broadcast();

    await _pcmController?.close();
    _pcmController = StreamController<List<Int16List>>();

    _isRecording = true;

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 2,
      toStreamInt16: _pcmController!.sink,
    );

    await _streamSubscription?.cancel();

    _streamSubscription = _pcmController!.stream.listen((buffer) {
      if (!_isRecording) return;

      final mono = <int>[];

      for (final chunk in buffer) {
        final int16 = Int16List.view(
          chunk.buffer,
          chunk.offsetInBytes,
          chunk.lengthInBytes ~/ 2,
        );
        mono.addAll(int16);
      }
      final result = _calculate(mono);
      if (_resultController != null && !_resultController!.isClosed) {
        _resultController!.add(result);
      }
    });
  }

  Future<void> stopRecording() async {
    _isRecording = false;

    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    await _pcmController?.close();
    _pcmController = null;

    await _resultController?.close();
    _resultController = null;
  }

  Future<void> dispose() async {
    await stopRecording();
    await _recorder.closeRecorder();
    _isInitialized = false;
  }
  int _calculate(List<int> samples) {
    if (samples.isEmpty) return 0;

    double sum = 0;
    for (final sample in samples) {
      sum += sample.abs();
    }
    return (sum / samples.length).round();
  }
}