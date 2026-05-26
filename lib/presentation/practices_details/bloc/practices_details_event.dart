part of 'practices_details_bloc.dart';

sealed class PracticesDetailsEvent {}

class LoadPractices extends PracticesDetailsEvent {
  final String id;
  LoadPractices(this.id);
}

class PlayPractices extends PracticesDetailsEvent {}

class PausePractices extends PracticesDetailsEvent {}

class ResumePractices extends PracticesDetailsEvent {}

class UpdatePosition extends PracticesDetailsEvent {
  final int currentMs;
  UpdatePosition(this.currentMs);
}

class UpdatePitch extends PracticesDetailsEvent {
  final double userPitchHz;
  UpdatePitch(this.userPitchHz);
}


class CompletePractices extends PracticesDetailsEvent {}