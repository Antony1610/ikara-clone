import '../../services/karaoke_audio_service.dart';
import '../karaoke_audio_repository.dart';
import '../practices_audio_repository.dart';

class KaraokeAudioRepositoryImpl implements KaraokeAudioRepository {
  final KaraokeAudioService _karaokeService;

  KaraokeAudioRepositoryImpl(this._karaokeService);

  @override
  Stream<double> get pitchStream => _karaokeService.pitchStream;

  @override
  Stream<int> get playbackProgressStream =>
      _karaokeService.playbackProgressStream;
  @override
  Stream<void> get completeStream => _karaokeService.onCompleteStream;

  @override
  Future<void> start(String audioUrl) => _karaokeService.start(audioUrl);

  @override
  Future<void> stop() => _karaokeService.stop();

  @override
  Future<void> pause() => _karaokeService.pause();

  @override
  Future<void> resume() => _karaokeService.resume();

  @override
  Future<void> dispose() => _karaokeService.dispose();
}