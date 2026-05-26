import 'package:flutter/services.dart';

class PitchDetectorService {
  static const _channel = MethodChannel('com.example.ikara_clone/pitch');
  bool _initialized = false;

  Future<void> initialize({
    double sampleRate = 44100,
    int bufferSize = 1024,
    double threshold = 0.15
}) async {
    await _channel.invokeMethod('initialize', {
      'sampleRate' : sampleRate,
      'bufferSize' : bufferSize,
      'threshold' : threshold
    });
    _initialized = true;
  }


  Future<double> getPitch(Uint8List samplesBytes) async {
    if (!_initialized) {
      throw StateError('Gọi initialize() trước khi dùng getPitch()');
    }

    final result = await _channel.invokeMethod<double>('getPitch', {
      'buffer' : samplesBytes
    });

    return (result ?? -1.0).roundToDouble();
  }


  Future<void> dispose() async {
    if (_initialized) {
      await _channel.invokeMethod('dispose');
      _initialized = false;
    }
  }
}