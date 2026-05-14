abstract class KaraokeAudioRepository {
  Stream<double> get pitchStream;
  Stream<int> get volumeStream;
  Stream<int> get playbackProgressStream;

  Future<void> start(String audioUrl);
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}