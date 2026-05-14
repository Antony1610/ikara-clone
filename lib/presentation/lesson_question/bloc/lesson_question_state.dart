part of 'lesson_question_bloc.dart';

sealed class LessonQuestionState extends Equatable {
  const LessonQuestionState();
  @override
  List<Object> get props => [];
}

class LessonQuestionInitial extends LessonQuestionState {}

class LessonQuestionLoading extends LessonQuestionState {}

class LessonQuestionError extends LessonQuestionState {
  final String message;
  const LessonQuestionError(this.message);
  @override
  List<Object> get props => [message];
}

class LessonQuestionLoaded extends LessonQuestionState {
  final String lessonId;
  final String lessonTitle;
  final List<Question> questions;
  final List<int?> userAnswer;
  final int currentIndex;
  final bool isCompleted;
  final int score;
  final List<QuestionResult> questionResult;
  final LessonResult? lessonResult; // nullable vì chưa có khi mới load

  const LessonQuestionLoaded({
    required this.lessonId,
    required this.lessonTitle,
    required this.questions,
    required this.userAnswer,
    required this.currentIndex,
    required this.isCompleted,
    required this.score,
    required this.questionResult,
    required this.lessonResult,
  });

  LessonQuestionLoaded copyWith({
    String? lessonId,
    String? lessonTitle,
    List<Question>? questions,
    List<int?>? userAnswer,
    int? currentIndex,
    bool? isCompleted,
    int? score,
    List<QuestionResult>? questionResult,
    LessonResult? lessonResult,
  }) {
    return LessonQuestionLoaded(
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      questions: questions ?? this.questions,
      userAnswer: userAnswer ?? this.userAnswer,
      currentIndex: currentIndex ?? this.currentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      questionResult: questionResult ?? this.questionResult,
      lessonResult: lessonResult ?? this.lessonResult,
    );
  }

  bool get isAllAnswered => userAnswer.every((a) => a != null);

  @override
  List<Object> get props => [
    lessonId, lessonTitle, questions, userAnswer,
    currentIndex, isCompleted, score, questionResult, ?lessonResult,
  ];
}
