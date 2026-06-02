part of 'performance_karaoke_bloc.dart';

abstract class PerformanceKaraokeState extends Equatable {
  const PerformanceKaraokeState();

  @override
  List<Object?> get props => [];
}

class InitialKaraoke extends PerformanceKaraokeState {}

class LoadingKaraoke extends PerformanceKaraokeState {}

class ErrorKaraoke extends PerformanceKaraokeState {
  final String message;
  const ErrorKaraoke(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadedKaraoke extends PerformanceKaraokeState {
  final PerformanceLesson lesson;
  final KarSong song;
  final int minPitch;
  final int maxPitch;
  final Map<int, double> hitDuration;
  final bool isPlaying;
  final int totalHitMs;
  final double userPitchHz;
  final int currentTimeMs;
  const LoadedKaraoke({
    required this.currentTimeMs,
    required this.userPitchHz,
    required this.lesson,
    required this.song,
    required this.minPitch,
    required this.maxPitch,
    required this.hitDuration,
    required this.isPlaying,
    required this.totalHitMs
  });

  LoadedKaraoke copyWith({
    PerformanceLesson? lesson,
    KarSong? song,
    int? minPitch,
    int? maxPitch,
    Map<int, double>? hitDuration,
    bool? isPlaying,
    int? totalHitMs,
    int? currentTimeMs,
    double? userPitchHz
  }) {
    return LoadedKaraoke(
      lesson: lesson ?? this.lesson,
      song: song ?? this.song,
      minPitch: minPitch ?? this.minPitch,
      maxPitch: maxPitch ?? this.maxPitch,
      hitDuration: hitDuration ?? this.hitDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      totalHitMs: totalHitMs ?? this.totalHitMs,
      currentTimeMs: currentTimeMs ?? this.currentTimeMs,
      userPitchHz: userPitchHz ?? this.userPitchHz
    );
  }

  @override
  List<Object?> get props => [
    lesson,
    song,
    minPitch,
    maxPitch,
    hitDuration,
    isPlaying,
    totalHitMs,
    currentTimeMs,
    userPitchHz
  ];
}

class CompletedKaraoke extends PerformanceKaraokeState {
  final int score;
  const CompletedKaraoke(this.score);
  @override
  List<Object> get props => [score];
}