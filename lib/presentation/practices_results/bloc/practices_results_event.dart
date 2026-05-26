part of 'practices_results_bloc.dart';

sealed class PracticesResultsEvent {}

class LoadPracticesResult extends PracticesResultsEvent {
  final int score;
  final PracticesPart practicesPart;
  final String status;
  LoadPracticesResult(this.score, this.practicesPart, this.status);
}