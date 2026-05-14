import '../../services/audio_service.dart';
import '../audio_repository.dart';


class AudioRepositoryImpl implements AudioRepository {
  final AudioService _audioService;

  AudioRepositoryImpl(this._audioService);

  @override
  Stream<int> get volumeStream => _audioService.resultStream;

  @override
  Future<void> init() => _audioService.initRecorder();

  @override
  Future<void> startRecording() => _audioService.startRecording();

  @override
  Future<void> stopRecording() => _audioService.stopRecording();

  @override
  Future<void> dispose() => _audioService.dispose();
}