import 'package:ikara_clone/data/model/model.dart';

abstract class PracticesRepository {
  Future<List<PracticesPart>> getListPractices();
  Future<PracticesPart?> getPractices(String id);
}