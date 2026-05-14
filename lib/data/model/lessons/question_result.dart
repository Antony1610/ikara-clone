import 'package:ikara_clone/data/model/lessons/lessons.dart';

class QuestionResult {
  final Question question;
  final String selectedAnswer;
  final bool isCorrect;
  QuestionResult({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
  });
}
