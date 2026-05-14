part of 'breathing_lesson_detail_bloc.dart';

sealed class BreathingLessonDetailEvent {}

class InitBreathing extends BreathingLessonDetailEvent {
  final String id;
  InitBreathing(this.id);
}
class StartBreathing extends BreathingLessonDetailEvent {}

class StopBreathing extends BreathingLessonDetailEvent {
  final bool isCompleted;
  StopBreathing({this.isCompleted = false});
}

class UpdateVolume extends BreathingLessonDetailEvent {
  final int sample;
  UpdateVolume(this.sample);
}

class TimerTicked extends BreathingLessonDetailEvent {
  final double elapsedSeconds;
  TimerTicked(this.elapsedSeconds);
}
