part of 'lesson_detail_bloc.dart';

sealed class LessonDetailState extends Equatable {
  const LessonDetailState();

  @override
  List<Object> get props => [];
}

class LessonDetailInitial extends LessonDetailState {}

class LessonDetailLoading extends LessonDetailState {}

class LessonDetailError extends LessonDetailState {
  final String message;
  const LessonDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class LessonDetailLoaded extends LessonDetailState {
  final String partId;
  final Lesson lesson;
  final List<Question> questions;
  final bool isVideoPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isSheetOpen;
  const LessonDetailLoaded({
    required this.partId,
    required this.lesson,
    required this.questions,
    this.isVideoPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isSheetOpen = false
  });

  LessonDetailLoaded copyWith({
    String? partId,
    Lesson? lesson,
    List<Question>? questions,
    bool? isVideoPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isSheetOpen
  }) {
    return LessonDetailLoaded(
      partId: partId ?? this.partId,
      lesson: lesson ?? this.lesson,
      questions: questions ?? this.questions,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isSheetOpen: isSheetOpen ?? this.isSheetOpen
    );

  }

  @override
  List<Object> get props => [
    partId,
    lesson,
    questions,
    isVideoPlaying,
    currentPosition,
    totalDuration,
    isSheetOpen
  ];
}
