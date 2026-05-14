part of 'performances_bloc.dart';

sealed class PerformancesState extends Equatable {
  const PerformancesState();

  @override
  List<Object> get props => [];
}

class PerformancesInitial extends PerformancesState {}

class PerformancesLoading extends PerformancesState {}

class PerformancesError extends PerformancesState {
  final String message;
  const PerformancesError(this.message);

  @override
  List<Object> get props => [message];
}

class PerformancesLoaded extends PerformancesState {
  final List<PerformanceLesson> performances;
  const PerformancesLoaded(this.performances);

  @override
  List<Object> get props => [performances];
}
