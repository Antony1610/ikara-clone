part of 'performance_detail_bloc.dart';

sealed class PerformanceDetailEvent {}

class LoadPerformanceDetail extends PerformanceDetailEvent {
  final String id;
  LoadPerformanceDetail(this.id);
}

class VideoPositionChanged extends PerformanceDetailEvent {
  final Duration position;
  VideoPositionChanged(this.position);
}

class VideoPlayPauseToggled extends PerformanceDetailEvent {}
