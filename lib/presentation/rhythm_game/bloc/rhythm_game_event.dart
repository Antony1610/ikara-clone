part of 'rhythm_game_bloc.dart';

sealed class RhythmGameEvent {}

class LoadGame extends RhythmGameEvent{
  final String partId;
  LoadGame(this.partId);
}

class StartGame extends RhythmGameEvent{}

class StopGame extends RhythmGameEvent{}

class UpdateTick extends RhythmGameEvent{
  final int deltaMs;
  UpdateTick(this.deltaMs);
}

class Tap extends RhythmGameEvent {}

class FinishedGame extends RhythmGameEvent {
  final String partId;
  FinishedGame(this.partId);
}

