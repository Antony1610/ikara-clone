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
  final dynamic lesson;
  final KarSong song;
  final int currentMs;
  final double userPitchHz;
  final int minPitch;
  final int maxPitch;
  final bool isPlaying;

  const LoadedKaraoke._({
    required this.lesson,
    required this.song,
    required this.currentMs,
    required this.userPitchHz,
    required this.minPitch,
    required this.maxPitch,
    required this.isPlaying,
  });

  factory LoadedKaraoke({
    required dynamic lesson,
    required KarSong song,
    int currentMs = 0,
    double userPitchHz = 0,
    bool isPlaying = true,
  }) {
    int minP = 40;
    int maxP = 80;
    if (song.notes.isNotEmpty) {
      minP = song.notes.map((n) => n.midiPitch).reduce(min);
      maxP = song.notes.map((n) => n.midiPitch).reduce(max);
    }
    return LoadedKaraoke._(
      lesson: lesson,
      song: song,
      currentMs: currentMs,
      userPitchHz: userPitchHz,
      minPitch: minP,
      maxPitch: maxP,
      isPlaying: isPlaying,
    );
  }

  LoadedKaraoke copyWith({
    int? currentMs,
    double? userPitchHz,
    bool? isPlaying,
  }) {
    return LoadedKaraoke._(
      lesson: lesson,
      song: song,
      currentMs: currentMs ?? this.currentMs,
      userPitchHz: userPitchHz ?? this.userPitchHz,
      minPitch: minPitch,
      maxPitch: maxPitch,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [lesson, song, currentMs, userPitchHz, isPlaying];
}
