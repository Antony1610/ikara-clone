import 'package:ikara_clone/data/model/lessons/lesson.dart';

class Part {
  final String indexId;
  final String id;
  final List<Lesson> lessons;
  final String title;
  Part({required this.indexId, required this.id, required this.lessons, required this.title});

  factory Part.fromJson(Map<String, dynamic> json, String indexId) {
    final lessonsRaw = json['lessons'];
    final List<({Map<String, dynamic> data, String indexId})> lessonEntries;

    if (lessonsRaw is Map) {
      lessonEntries = Map<String, dynamic>.from(lessonsRaw)
          .entries
          .where((e) => e.value is Map)
          .map((e) => (
      data: Map<String, dynamic>.from(e.value as Map),
      indexId: e.key.toString(),
      ))
          .toList();
    } else if (lessonsRaw is List) {
      lessonEntries = lessonsRaw
          .asMap()
          .entries
          .where((e) => e.value is Map)
          .map((e) => (
      data: Map<String, dynamic>.from(e.value as Map),
      indexId: e.key.toString(),
      ))
          .toList();
    } else {
      lessonEntries = [];
    }

    return Part(
      indexId: indexId,
      id: (json['id'] ?? '').toString(),
      lessons: lessonEntries
          .map((entry) => Lesson.fromJson(entry.data, entry.indexId))
          .toList(),
      title: json['title'] ?? '',
    );
  }
}