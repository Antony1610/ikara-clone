abstract class AudioRepository {
  Stream<int> get volumeStream;

  Future<void> init();
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<void> dispose();
}