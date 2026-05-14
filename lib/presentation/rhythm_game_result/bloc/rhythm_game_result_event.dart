part of 'rhythm_game_result_bloc.dart';

sealed class RhythmGameResultEvent {}

class LoadResultEvent extends RhythmGameResultEvent {
  final RhythmsResult result;
  LoadResultEvent(this.result);
}