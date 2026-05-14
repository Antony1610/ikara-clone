import 'package:ikara_clone/data/model/model.dart';

abstract class BreathsRepository {
  Future<List<BreathsPart>> getParts();
  Future<BreathsPart> getDetailParts(String partId);
}
