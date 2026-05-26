abstract class PracticesAudioRepository {
  Stream<double> get pitchStream;
  Stream<Duration> get positionStream;
  Stream<void> get completeStream;
  Future<void> load(String fileName);
  Future<void> start();
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}