part of 'breathing_lesson_detail_bloc.dart';

sealed class BreathingLessonDetailState extends Equatable {
  const BreathingLessonDetailState();
  @override
  List<Object> get props => [];
}

class DetailInitial extends BreathingLessonDetailState {}

class DetailLoading extends BreathingLessonDetailState {}

class DetailError extends BreathingLessonDetailState {
  final String message;
  const DetailError(this.message);
  @override
  List<Object> get props => [message];
}

class DetailLoaded extends BreathingLessonDetailState {
  final int currentVolumeLevel;
  final double elapsedSeconds;
  final bool isRecording;
  final double targetDuration;
  final BreathsPart breathsPart;
  final int score;
  const DetailLoaded({
    this.currentVolumeLevel = 0,
    this.elapsedSeconds = 0.0,
    this.targetDuration = 0,
    this.isRecording = false,
    required this.breathsPart,
    this.score = 0,
  });
  DetailLoaded copyWith({
    int? currentVolumeLevel,
    double? elapsedSeconds,
    bool? isRecording,
    double? targetDuration,
    BreathsPart? breathsPart,
    int? score,
  }) {
    return DetailLoaded(
      currentVolumeLevel: currentVolumeLevel ?? this.currentVolumeLevel,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRecording: isRecording ?? this.isRecording,
      targetDuration: targetDuration ?? this.targetDuration,
      breathsPart: breathsPart ?? this.breathsPart,
      score: score ?? this.score,
    );
  }

  @override
  List<Object> get props => [
    currentVolumeLevel,
    elapsedSeconds,
    isRecording,
    targetDuration,
    breathsPart,
    score,
  ];
}

class DetailCompleted extends BreathingLessonDetailState {
  final String id;
  final BreathsResult result;
  final int score;
  final String type;
  final double duration;

  const DetailCompleted({
    required this.id,
    required this.result,
    required this.score,
    required this.type,
    required this.duration,
  });

  @override
  List<Object> get props => [id, result, score, type, duration];
}