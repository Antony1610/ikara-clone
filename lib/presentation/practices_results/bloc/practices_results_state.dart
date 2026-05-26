part of 'practices_results_bloc.dart';

sealed class PracticesResultsState extends Equatable {
  const PracticesResultsState();
  @override
  List<Object> get props => [];
}

class InitialResult extends PracticesResultsState {}

class LoadingResult extends PracticesResultsState {}

class ErrorResult extends PracticesResultsState {
  final String message;
  const ErrorResult(this.message);

  @override
  List<Object> get props => [message];
}

class LoadedResult extends PracticesResultsState {
  final int score;
  final PracticesPart practicesPart;
  final String status;
  final String feedbackText;
  final int stars;
  final bool isPass;
  const LoadedResult({
    required this.score,
    required this.practicesPart,
    required this.status,
    required this.feedbackText,
    required this.stars,
    required this.isPass,
  });
  @override
  List<Object> get props => [
    score,
    practicesPart,
    status,
    feedbackText,
    stars,
    isPass,
  ];
}
