part of 'performance_karaoke_bloc.dart';

sealed class PerformanceKaraokeEvent {}

class LoadPerformance extends PerformanceKaraokeEvent {
  final String id;
  LoadPerformance(this.id);
}


// class UpdateUserPitch extends PerformanceKaraokeEvent {
//   final double pitchHz;
//   final int currentMs;
//   UpdateUserPitch(this.pitchHz, this.currentMs);
// }

class UpdatePosition extends PerformanceKaraokeEvent {
  final int currentMs;
  UpdatePosition(this.currentMs);
}

class UpdatePitch extends PerformanceKaraokeEvent {
  final double userPitchHz;
  UpdatePitch(this.userPitchHz);
}

class PauseKaraoke extends PerformanceKaraokeEvent {}
class ResumeKaraoke extends PerformanceKaraokeEvent {}

class CompleteKaraoke extends PerformanceKaraokeEvent {}