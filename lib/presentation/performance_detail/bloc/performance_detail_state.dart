part of 'performance_detail_bloc.dart';

sealed class PerformanceDetailState extends Equatable {
  const PerformanceDetailState();

  @override
  List<Object> get props => [];
}

class PerformanceDetailInitial extends PerformanceDetailState {}

class PerformanceDetailLoading extends PerformanceDetailState {}

class PerformanceDetailError extends PerformanceDetailState {
  final String message;
  const PerformanceDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class PerformanceDetailLoaded extends PerformanceDetailState {
  final PerformanceLesson lesson;
  final bool isVideoPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  const PerformanceDetailLoaded({
    required this.lesson,
    this.isVideoPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });
  PerformanceDetailLoaded copyWith({
    PerformanceLesson? lesson,
    bool? isVideoPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return PerformanceDetailLoaded(
      lesson: lesson ?? this.lesson,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  List<Object> get props => [
    lesson,
    isVideoPlaying,
    currentPosition,
    totalDuration,
  ];
}
