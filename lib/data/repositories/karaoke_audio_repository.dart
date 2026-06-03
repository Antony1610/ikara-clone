abstract class KaraokeAudioRepository {
  Stream<double> get pitchStream;
  Stream<Duration> get positionStream;
  Stream<void> get completeStream;
  Future<void> start(String audioUrl);
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  // Future<void> seekTo(Duration position);
  Future<void> dispose();
}