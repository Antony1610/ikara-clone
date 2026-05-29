import 'package:ikara_clone/data/model/model.dart';

import '../model/performances/kar_song.dart';

abstract class PerformanceRepository {
  Future<List<PerformanceLesson>> getListPerformance();
  Future<PerformanceLesson> getDetailPerformance(String id);
  Future<KarSong> getKarSong(String midiLink);
}
