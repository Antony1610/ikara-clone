part of 'performance_karaoke_bloc.dart';

sealed class PerformanceKaraokeEvent {}

class LoadPerformance extends PerformanceKaraokeEvent {
  final String id;
  LoadPerformance(this.id);
}

class UpdatePlaybackTime extends PerformanceKaraokeEvent {
  final int currentMs;
  UpdatePlaybackTime(this.currentMs);
}

class UpdateUserPitch extends PerformanceKaraokeEvent {
  final double pitchHz;
  UpdateUserPitch(this.pitchHz);
}

class PauseKaraoke extends PerformanceKaraokeEvent {}
class ResumeKaraoke extends PerformanceKaraokeEvent {}

class CompleteKaraoke extends PerformanceKaraokeEvent {}