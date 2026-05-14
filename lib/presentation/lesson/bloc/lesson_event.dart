part of 'lesson_bloc.dart';

sealed class LessonEvent {}

class LoadParts extends LessonEvent {
  LoadParts();
}

class LessonPageIndexChanged extends LessonEvent {
  final int index;
  LessonPageIndexChanged(this.index);
}

class LessonSelected extends LessonEvent {
  final String lessonDocId;
  final String partId;
  final String lessonChildId;
  LessonSelected(this.lessonDocId, this.partId, this.lessonChildId);
}

class LoadLessons extends LessonEvent {
  final String lessonDocId;
  final String partId;
  LoadLessons(this.lessonDocId, this.partId);
}

class LessonCompleted extends LessonEvent {
  final String lessonId;
  LessonCompleted(this.lessonId);
}
