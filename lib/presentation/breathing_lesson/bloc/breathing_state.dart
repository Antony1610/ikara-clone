part of 'breathing_bloc.dart';

sealed class BreathingState extends Equatable {
  const BreathingState();

  @override
  List<Object> get props => [];
}

class BreathingInitial extends BreathingState {}

class BreathingLoading extends BreathingState {}

class BreathingError extends BreathingState {
  final String message;
  const BreathingError(this.message);
  @override
  List<Object> get props => [message];
}

class PartsLoaded extends BreathingState {
  final List<BreathsPart> parts;
  const PartsLoaded(this.parts);
  @override
  List<Object> get props => [parts];
}
