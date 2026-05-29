import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/model/performances/kar_song.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import '../../../data/repositories/karaoke_audio_repository.dart';
import 'package:equatable/equatable.dart';
part 'performance_karaoke_event.dart';
part 'performance_karaoke_state.dart';

class PerformanceKaraokeBloc
    extends Bloc<PerformanceKaraokeEvent, PerformanceKaraokeState> {
  final PerformanceRepository repository;
  final KaraokeAudioRepository karaokeAudioRepository;

  StreamSubscription? _pitchSubscription;
  StreamSubscription? _playbackSubscription;

  int _lastMs = 0;
  double _latestPitch = 0.0;
  bool _isComplete = false;

  PerformanceKaraokeBloc({
    required this.repository,
    required this.karaokeAudioRepository,
  }) : super(InitialKaraoke()) {
    on<LoadPerformance>(_onLoadPerformance);
    on<UpdatePlaybackTime>(_onUpdatePlaybackTime);
    on<UpdateUserPitch>(_onUpdateUserPitch);
    on<PauseKaraoke>(_onPauseKaraoke);
    on<ResumeKaraoke>(_onResumeKaraoke);
    on<CompleteKaraoke>(_onCompleteKaraoke);
  }

  void _startSubscriptions() {
    _playbackSubscription = karaokeAudioRepository
        .playbackProgressStream
        .listen((ms) {
      if (!isClosed) add(UpdatePlaybackTime(ms));
    });

    _pitchSubscription = karaokeAudioRepository.pitchStream.listen((pitchHz) {
      if (!isClosed) add(UpdateUserPitch(pitchHz));
    });
  }

  Future<void> _onLoadPerformance(
      LoadPerformance event, Emitter emit) async {
    await _cancelSubscriptions();

    _lastMs = 0;
    _latestPitch = 0.0;
    _isComplete = false;

    emit(LoadingKaraoke());

    try {
      final lesson = await repository.getDetailPerformance(event.id);
      final song = await repository.getKarSong(lesson.midiLink);

      final pitches = song.notes.map((n) => n.midiPitch);
      final minPitch = pitches.reduce(min) - 2;
      final maxPitch = pitches.reduce(max) + 2;

      emit(LoadedKaraoke(
        lesson: lesson,
        song: song,
        currentMs: 0,
        userPitchHz: 0.0,
        minPitch: minPitch,
        maxPitch: maxPitch,
        hitDuration: const {},
        isPlaying: true,
        totalHitMs: 0
      ));

      await karaokeAudioRepository.start(lesson.karaokeLink);
      if (!isClosed) _startSubscriptions();

    } on DioException catch (e) {
      emit(ErrorKaraoke('Lỗi kết nối mạng: ${e.message}'));
    } catch (e) {
      emit(ErrorKaraoke(e.toString()));
    }
  }

  void _onUpdatePlaybackTime(UpdatePlaybackTime event, Emitter emit) {
    if (_isComplete) return;

    final s = state;
    if (s is! LoadedKaraoke) return;
    if (!s.isPlaying) return;

    final currentMs = event.currentMs;

    int delta = currentMs - _lastMs;
    if (delta <= 0 || delta > 200) delta = 50;
    _lastMs = currentMs;

    if (s.song.notes.isNotEmpty) {
      final last = s.song.notes.last;
      if (currentMs >= last.startMs + last.durationMs) {
        _isComplete = true;
        add(CompleteKaraoke());
        return;
      }
    }

    final updatedHit = Map<int, double>.from(s.hitDuration);
    int newTotalHitMs = s.totalHitMs;
    if (_latestPitch > 50) {
      final userMidi = 69.0 + 12.0 * (log(_latestPitch / 440.0) / ln2);
      final notes = s.song.notes;

      int lo = 0, hi = notes.length - 1;
      while (lo <= hi) {
        final mid = (lo + hi) >> 1;
        final note = notes[mid];
        if (currentMs < note.startMs) {
          hi = mid - 1;
        } else if (currentMs > note.startMs + note.durationMs) {
          lo = mid + 1;
        } else {
          if ((userMidi - note.midiPitch).abs() <= 0.4) {
            newTotalHitMs += delta;
            updatedHit[note.startMs] =
                (updatedHit[note.startMs] ?? 0.0) + delta;
          }
          break;
        }
      }
    }

    emit(s.copyWith(
      currentMs: currentMs,
      hitDuration: updatedHit,
      totalHitMs: newTotalHitMs
    ));
  }

  void _onUpdateUserPitch(UpdateUserPitch event, Emitter emit) {
    if (_isComplete) return;
    _latestPitch = event.pitchHz;
    final s = state;
    if (s is! LoadedKaraoke) return;
    if (!s.isPlaying) return;
    emit(s.copyWith(userPitchHz: _latestPitch));
  }

  void _onPauseKaraoke(PauseKaraoke event, Emitter emit) {
    final s = state;
    if (s is! LoadedKaraoke) return;
    karaokeAudioRepository.pause();
    emit(s.copyWith(isPlaying: false));
  }

  void _onResumeKaraoke(ResumeKaraoke event, Emitter emit) {
    final s = state;
    if (s is! LoadedKaraoke) return;
    karaokeAudioRepository.resume();
    emit(s.copyWith(isPlaying: true));
  }

  Future<void> _onCompleteKaraoke(CompleteKaraoke event, Emitter emit) async {
    final s = state;
    if (s is! LoadedKaraoke) return;
    _isComplete = true;
    await _cancelSubscriptions();
    await karaokeAudioRepository.stop();
    final totalNoteMs = s.song.notes.fold<int>(0, (sum, n) => sum + n.durationMs);
    final score = totalNoteMs > 0 ? ((s.totalHitMs / totalNoteMs)*100).clamp(0, 100).round() : 0;
    emit(CompletedKaraoke(score));
  }

  Future<void> _cancelSubscriptions() async {
    await _pitchSubscription?.cancel();
    await _playbackSubscription?.cancel();
    _pitchSubscription = null;
    _playbackSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    await karaokeAudioRepository.stop();
    return super.close();
  }
}