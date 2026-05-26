part of 'practices_details_bloc.dart';

sealed class PracticesDetailsState extends Equatable {
  const PracticesDetailsState();

  @override
  List<Object> get props => [];
}

class InitialPractices extends PracticesDetailsState {}

class LoadingPractices extends PracticesDetailsState {}

class ErrorPractices extends PracticesDetailsState {
  final String message;
  const ErrorPractices(this.message);

  @override
  List<Object> get props => [message];
}

class LoadedPractices extends PracticesDetailsState {
  final List<MidiNotePractices> notes;
  final PracticesPart practices;
  final int currentTimeMs;
  final bool isPlaying;
  final double userPitchHz;
  final int score;
  final int totalHitMs;
  final int lastTickMs;
  final Map<int, double> hitDuration;
  final bool hasStarted;
  final bool showOverlay;
  const LoadedPractices({
    required this.notes,
    required this.practices,
    this.currentTimeMs = 0,
    required this.userPitchHz,
    this.isPlaying = false,
    this.score = 0,
    required this.totalHitMs,
    required this.lastTickMs,
    this.hitDuration = const {},
    this.hasStarted = false,
    this.showOverlay = false
  });

  LoadedPractices copyWith({
    List<MidiNotePractices>? notes,
    PracticesPart? practices,
    int? currentTimeMs,
    bool? isPlaying,
    double? userPitchHz,
    int? score,
    int? totalHitMs,
    int? lastTickMs,
    Map<int, double>? hitDuration,
    bool? hasStarted,
    bool? showOverlay
  }) {
    return LoadedPractices(
      notes: notes ?? this.notes,
      practices: practices ?? this.practices,
      currentTimeMs: currentTimeMs ?? this.currentTimeMs,
      userPitchHz: userPitchHz ?? this.userPitchHz,
      isPlaying: isPlaying ?? this.isPlaying,
      score: score ?? this.score,
      totalHitMs: totalHitMs ?? this.totalHitMs,
      lastTickMs: lastTickMs ?? this.lastTickMs,
      hitDuration: hitDuration ?? this.hitDuration,
      hasStarted: hasStarted ?? this.hasStarted,
      showOverlay: showOverlay ?? this.showOverlay
    );
  }

  @override
  List<Object> get props => [
    notes,
    practices,
    currentTimeMs,
    userPitchHz,
    isPlaying,
    score,
    totalHitMs,
    lastTickMs,
    hitDuration,
    hasStarted,
    showOverlay
  ];
}

class FinishedPractices extends PracticesDetailsState {
  final int score;
  final PracticesPart practicesPart;
  final String status;
  const FinishedPractices({
    required this.score,
    required this.practicesPart,
    required this.status,
  });
  @override
  List<Object> get props => [score, practicesPart, status];
}
