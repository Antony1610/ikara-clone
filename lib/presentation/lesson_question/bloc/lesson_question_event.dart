part of 'lesson_question_bloc.dart';

sealed class LessonQuestionEvent {}

class LoadLessonQuestion extends LessonQuestionEvent {
  final String partId;
  final String lessonId;
  final String lessonRealId;
  final String title;
  LoadLessonQuestion(this.partId, this.lessonId,this.lessonRealId, this.title);
}

class SelectAnswer extends LessonQuestionEvent{
  final int answerIndex;
  SelectAnswer(this.answerIndex);
}

class NextQuestion extends LessonQuestionEvent {}

class SubmitQuiz extends LessonQuestionEvent {}
