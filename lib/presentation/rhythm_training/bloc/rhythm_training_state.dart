part of 'rhythm_training_bloc.dart';

sealed class RhythmTrainingState extends Equatable {
  const RhythmTrainingState();
  @override
  List<Object> get props => [];
}

class RhythmInitial extends RhythmTrainingState {}

class RhythmLoading extends RhythmTrainingState {}

class RhythmError extends RhythmTrainingState {
  final String message;
  const RhythmError(this.message);
  @override
  List<Object> get props => [message];
}

class RhythmLoaded extends RhythmTrainingState {
  final List<RhythmsPart> parts;
  const RhythmLoaded(this.parts);
  @override
  List<Object> get props => [parts];
}
