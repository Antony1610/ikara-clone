import 'package:ikara_clone/data/repositories/practices_audio_repository.dart';
import 'package:ikara_clone/data/services/practices_audio_service.dart';

class PracticesAudioRepositoryImpl implements PracticesAudioRepository {
  final PracticesAudioService _service;


  PracticesAudioRepositoryImpl(this._service);

  @override
  Future<void> load(String fileName) => _service.load(fileName);
  @override
  Future<void> start() => _service.start();
  @override
  Future<void> stop() => _service.stop();

  @override
  Future<void> pause() => _service.pause();

  @override
  Future<void> resume() => _service.resume();

  @override
  Future<void> dispose() => _service.dispose();

  @override
  Stream<double> get pitchStream => _service.pitchStream;

  @override
  Stream<Duration> get positionStream => _service.positionStream;

  @override
  Stream<void> get completeStream => _service.onCompleteStream;
}
