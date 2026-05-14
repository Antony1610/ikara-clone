import 'package:ikara_clone/data/model/lessons/question_result.dart';

class LessonResult {
  final String lessonId;
  final String lessonTitle;
  final int totalQuestion;
  final int correctCount;
  final List<QuestionResult> questionResults;

  LessonResult({
    required this.lessonId,
    required this.lessonTitle,
    required this.totalQuestion,
    required this.correctCount,
    required this.questionResults,
  });
}
