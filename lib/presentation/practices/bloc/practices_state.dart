part of 'practices_bloc.dart';

sealed class PracticesState extends Equatable{
  const PracticesState();

  @override
  List<Object> get props => [];
}

class PracticesInitial extends PracticesState {}

class PracticesLoading extends PracticesState {}

class PracticesError extends PracticesState {
  final String message;
  const PracticesError(this.message);
  @override
  List<Object> get props => [];
}

class PracticesLoaded extends PracticesState {
  final List<PracticesPart> parts;
  final Map<int, int> starCount;
  const PracticesLoaded(this.parts, this.starCount);
  @override
  List<Object> get props => [parts];
}

