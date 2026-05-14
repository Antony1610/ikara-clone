part of 'lesson_detail_bloc.dart';

sealed class LessonDetailEvent {}

class LoadLessonDetail extends LessonDetailEvent {
  final String partId;
  final String lessonId;
  LoadLessonDetail(this.partId, this.lessonId);
}

class VideoPositionChanged extends LessonDetailEvent {
  final Duration position;
  VideoPositionChanged(this.position);
}

class VideoPlayPauseToggled extends LessonDetailEvent {}

class StartQuiz extends LessonDetailEvent {}

class QuizSheetOpened extends LessonDetailEvent {}

class QuizSheetClosed extends LessonDetailEvent {}
