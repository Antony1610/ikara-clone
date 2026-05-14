import 'package:ikara_clone/data/model/model.dart';

abstract class RhythmsRepository {
  Future<List<RhythmsPart>> getRhythmsList();
  Future<RhythmsPart?> getRhythmsById(String id);
}
