import 'package:ikara_clone/data/model/lessons/question.dart';

class Lesson {
  final String id;
  final String lessonTitle;
  final List<String> lessonFocus;
  final List<Question> questions;
  final String videoUrl;
  Lesson({
    required this.id,
    required this.lessonTitle,
    required this.lessonFocus,
    required this.questions,
    required this.videoUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json, String id) {
    return Lesson(
      id: id,
      lessonTitle: json['lessonTitle'] ?? '',
      lessonFocus: List<String>.from(json['lessonFocus'] ?? []),
      questions: (json['questions'] as List? ?? [])
          .asMap()
          .entries
          .map(
            (entry) => Question.fromJson(
              Map<String, dynamic>.from(entry.value),
              entry.key.toString(),
            ),
          )
          .toList(),

      videoUrl: json['videoUrl'] ?? '',
    );
  }
}
