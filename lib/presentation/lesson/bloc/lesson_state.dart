part of 'lesson_bloc.dart';

sealed class LessonState extends Equatable {
  const LessonState();
  @override
  List<Object> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonError extends LessonState {
  final String message;
  const LessonError(this.message);
  @override
  List<Object> get props => [message];
}

class PartsLoaded extends LessonState {
  final List<Part> parts;
  final int currentIndex;
  const PartsLoaded({required this.parts, this.currentIndex = 0});
  PartsLoaded copyWith({List<Part>? parts, int? currentIndex}) {
    return PartsLoaded(
      parts: parts ?? this.parts,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [parts, currentIndex];
}

class LessonLoaded extends LessonState {
  final List<Lesson> lessons;
  final Part selectedPart;
  final int currentIndex;
  final Set<String> completedLessonId;

  const LessonLoaded({
    required this.selectedPart,
    required this.lessons,
    this.currentIndex = 0,
    this.completedLessonId = const {},
  });

  LessonLoaded copyWith({
    Part? selectedPart,
    List<Lesson>? lessons,
    int? currentIndex,
    Set<String>? completedLessonId,
  }) {
    return LessonLoaded(
      selectedPart: selectedPart ?? this.selectedPart,
      lessons: lessons ?? this.lessons,
      currentIndex: currentIndex ?? this.currentIndex,
      completedLessonId: completedLessonId ?? this.completedLessonId,
    );
  }

  @override
  List<Object> get props => [
    selectedPart,
    lessons,
    currentIndex,
    completedLessonId,
  ];
}
