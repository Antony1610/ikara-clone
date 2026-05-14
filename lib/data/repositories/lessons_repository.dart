import 'package:ikara_clone/data/model/model.dart';

abstract class LessonsRepository {
  Future<List<Part>> getParts();
  Future<List<Lesson>> getLesson(String partId);
  Future<Lesson> getDetailLesson(String partId, String lessonChildId);
  Future<List<Question>> getQuestion(String partId, String lessonChildId);
}
