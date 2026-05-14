part of 'performances_bloc.dart';

sealed class PerformancesEvent {}

class LoadPerformances extends PerformancesEvent {
  LoadPerformances();
}
