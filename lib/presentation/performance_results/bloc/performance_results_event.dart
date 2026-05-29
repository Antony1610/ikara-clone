part of 'performance_results_bloc.dart';

sealed class PerformanceResultsEvent {}

class LoadPerformanceResult extends PerformanceResultsEvent {
  final int score;
  LoadPerformanceResult(this.score);
}