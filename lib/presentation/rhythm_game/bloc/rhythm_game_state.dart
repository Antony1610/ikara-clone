part of 'rhythm_game_bloc.dart';

sealed class RhythmGameState extends Equatable {
  const RhythmGameState();
  @override
  List<Object> get props => [];
}

class RhythmGameInitial extends RhythmGameState {}

class RhythmGameLoading extends RhythmGameState {}

class RhythmGameError extends RhythmGameState {
  final String message;
  const RhythmGameError(this.message);
  @override
  List<Object> get props => [message];
}

class RhythmGameLoaded extends RhythmGameState {
  final String partId;
  final int lessonId;
  final List<Note> notes;
  final List<TappedNote> tappedNote;
  final int currentTimeMs;
  final String feedbackText;
  final String title;
  final bool isPlaying;
  final bool justStarted;
  final int tapCount;
  final String pattern;
  const RhythmGameLoaded({
    required this.partId,
    this.lessonId = 0,
    this.notes = const [],
    this.tappedNote = const [],
    this.currentTimeMs = 0,
    this.feedbackText = '',
    this.title = '',
    this.justStarted = false,
    this.isPlaying = false,
    this.tapCount = 0,
    this.pattern = '',
  });
  RhythmGameLoaded copyWith({
    String? partId,
    int? lessonId,
    List<Note>? notes,
    List<TappedNote>? tappedNote,
    int? currentTimeMs,
    String? feedbackText,
    String? title,
    bool? isPlaying,
    bool? justStarted,
    int? tapCount,
    String? pattern
  }) {
    return RhythmGameLoaded(
      partId: partId ?? this.partId,
      lessonId: lessonId ?? this.lessonId,
      notes: notes ?? this.notes,
      tappedNote: tappedNote ?? this.tappedNote,
      currentTimeMs: currentTimeMs ?? this.currentTimeMs,
      feedbackText: feedbackText ?? this.feedbackText,
      title: title ?? this.title,
      isPlaying: isPlaying ?? this.isPlaying,
      justStarted: justStarted ?? this.justStarted,
      tapCount: tapCount ?? this.tapCount,
      pattern: pattern ?? this.pattern
    );
  }

  @override
  List<Object> get props => [
    partId,
    notes,
    tappedNote,
    currentTimeMs,
    feedbackText,
    title,
    isPlaying,
    justStarted,
    tapCount
  ];
}

class RhythmGameCompleted extends RhythmGameState {
  final RhythmsResult result;

  const RhythmGameCompleted(this.result);

  @override
  List<Object> get props => [result];
}