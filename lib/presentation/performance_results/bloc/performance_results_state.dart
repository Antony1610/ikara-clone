part of 'performance_results_bloc.dart';

sealed class PerformanceResultsState extends Equatable {
  const PerformanceResultsState();
  @override
  List<Object> get props => [];
}

class InitialResult extends PerformanceResultsState {}

class LoadingResult extends PerformanceResultsState {}

class ErrorResult extends PerformanceResultsState {
  final String message;
  const ErrorResult(this.message);
}

class LoadedResult extends PerformanceResultsState {
  final int score;
  final String feedbackText;
  final int stars;
  const LoadedResult({
    required this.score,
    required this.feedbackText,
    required this.stars,
  });
  LoadedResult copyWith({int? score, String? feedbackText, int? stars}) {
    return LoadedResult(
      score: score ?? this.score,
      feedbackText: feedbackText ?? this.feedbackText,
      stars: stars ?? this.stars,
    );
  }

  @override
  List<Object> get props => [score, feedbackText, stars];
}
