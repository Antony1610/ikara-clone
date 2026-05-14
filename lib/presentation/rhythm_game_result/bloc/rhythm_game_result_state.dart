part of 'rhythm_game_result_bloc.dart';

sealed class RhythmGameResultState extends Equatable {
  const RhythmGameResultState();

  @override
  List<Object> get props => [];
}

class RhythmGameResultInitial extends RhythmGameResultState {}

class RhythmGameResultLoading extends RhythmGameResultState {}

class RhythmGameResultError extends RhythmGameResultState {
  final String message;
  const RhythmGameResultError(this.message);
  @override
  List<Object> get props => [message];
}

class RhythmGameResultLoaded extends RhythmGameResultState {
  final RhythmsResult result;
  final int starCount;
  final String feedbackMessage;
  final bool isPassed;

  const RhythmGameResultLoaded({
    required this.result,
    required this.starCount,
    required this.feedbackMessage,
    required this.isPassed,
  });

  @override
  List<Object> get props => [result, starCount, feedbackMessage, isPassed];
}
