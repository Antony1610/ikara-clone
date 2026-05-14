import 'package:ikara_clone/data/model/lessons/lesson.dart';

class Part {
  final String id;
  final List<Lesson> lessons;
  final String title;
  Part({required this.id, required this.lessons, required this.title});

  factory Part.fromJson(Map<String, dynamic> json, String id) {
    final lessonsRaw = json['lessons'];
    final List<Map<String, dynamic>> lessonsJson;

    if (lessonsRaw is Map) {
      final lessonsMap = Map<String, dynamic>.from(lessonsRaw);
      lessonsJson = lessonsMap.entries.where((entry) => entry.value is Map).map(
        (entry) {
          final lesson = Map<String, dynamic>.from(entry.value as Map);
          final lessonId = entry.key.toString();
          return {...lesson, 'id': lessonId};
        },
      ).toList();
    } else if (lessonsRaw is List) {
      lessonsJson = lessonsRaw
          .asMap()
          .entries
          .where((entry) => entry.value is Map)
          .map((entry) {
            final lesson = Map<String, dynamic>.from(entry.value as Map);
            final lessonId = entry.key.toString();
            return {...lesson, 'id': lessonId};
          })
          .toList();
    } else {
      lessonsJson = [];
    }

    return Part(
      id: id,
      lessons: lessonsJson
          .map((data) => Lesson.fromJson(data, (data['id'] ?? '').toString()))
          .toList(),
      title: json['title'] ?? '',
    );
  }
}
