import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/model/performances/kar_song.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import '../../../data/repositories/karaoke_audio_repository.dart';

part 'performance_karaoke_event.dart';
part 'performance_karaoke_state.dart';

class PerformanceKaraokeBloc extends Bloc<PerformanceKaraokeEvent, PerformanceKaraokeState> {
  final PerformanceRepository repository;
  final KaraokeAudioRepository karaokeAudioRepository;

  int _lastMs = 0;
  double _latestPitch = 0.0;
  bool _isComplete = false;
  int? _lastHitNoteStartMs;
  late final StreamSubscription _completeSub;
  PerformanceKaraokeBloc({
    required this.repository,
    required this.karaokeAudioRepository,
  }) : super(InitialKaraoke()) {
    on<LoadPerformance>(_onLoadPerformance);
    // on<UpdateUserPitch>(_onUpdateUserPitch);
    on<PauseKaraoke>(_onPauseKaraoke);
    on<ResumeKaraoke>(_onResumeKaraoke);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdatePitch>(_onUpdatePitch);
    on<CompleteKaraoke>(_onCompleteKaraoke);
    _completeSub = karaokeAudioRepository.completeStream.listen((_) {
      if (!_isComplete) {
        add(CompleteKaraoke());
      }
    });
  }

  Future<void> _onLoadPerformance(LoadPerformance event, Emitter emit) async {
    _lastMs = 0;
    _isComplete = false;
    emit(LoadingKaraoke());

    try {
      final lesson = await repository.getDetailPerformance(event.id);
      final song = await repository.getKarSong(lesson.midiLink);

      final pitches = song.notes.map((n) => n.midiPitch);
      final minPitch = pitches.reduce(min) - 2;
      final maxPitch = pitches.reduce(max) + 2;
      await karaokeAudioRepository.start(lesson.karaokeLink);

      emit(LoadedKaraoke(
          lesson: lesson,
          song: song,
          minPitch: minPitch,
          maxPitch: maxPitch,
          hitDuration: const {},
          hitMs: const {},
          isPlaying: true,
          totalHitMs: 0,
          currentTimeMs: 0,
          userPitchHz: 0.0
      ));

    } catch (e) {
      emit(ErrorKaraoke(e.toString()));
    }
  }

  // void _onUpdateUserPitch(UpdateUserPitch event, Emitter emit) {
  //   if (_isComplete) return;
  //   final s = state;
  //   if (s is! LoadedKaraoke || !s.isPlaying) return;
  //
  //   final currentMs = event.currentMs;
  //   final pitch = event.pitchHz;
  //
  //   // HIT SCORING LOGIC
  //   debugPrint("pitch: $pitch");
  //   if (pitch > 50) {
  //     final userMidi = 69.0 + 12.0 * (log(pitch / 440.0) / ln2);
  //     final notes = s.song.notes;
  //
  //     // Binary search for note at current time
  //     int lo = 0, hi = notes.length - 1;
  //     while (lo <= hi) {
  //       final mid = (lo + hi) >> 1;
  //       final note = notes[mid];
  //       if (currentMs < note.startMs) {
  //         hi = mid - 1;
  //       } else if (currentMs > note.startMs + note.durationMs) {
  //         lo = mid + 1;
  //       } else {
  //         // Check if pitch matches
  //         if ((userMidi - note.midiPitch).abs() <= 0.4) {
  //           int delta = currentMs - _lastMs;
  //           if (delta <= 0 || delta > 100) delta = 16; // Approx 1 frame
  //
  //           final updatedHit = Map<int, double>.from(s.hitDuration);
  //           updatedHit[note.startMs] = (updatedHit[note.startMs] ?? 0.0) + delta;
  //           debugPrint('hit duration: $updatedHit');
  //           emit(s.copyWith(
  //             hitDuration: updatedHit,
  //             totalHitMs: s.totalHitMs + delta,
  //           ));
  //         }
  //         break;
  //       }
  //     }
  //   }
  //   _lastMs = currentMs;
  // }

  void _onUpdatePitch(UpdatePitch event, Emitter emit) {
    if (_isComplete) return;
    _latestPitch = event.userPitchHz;
    final s = state;
    if (s is! LoadedKaraoke) return;
    if (!s.isPlaying) return;
    debugPrint('UserPitchHz: $_latestPitch');
    emit(s.copyWith(userPitchHz: _latestPitch));
  }

  void _onUpdatePosition(UpdatePosition event, Emitter emit) {
    if (_isComplete) return;

    final s = state;
    final currentTimeMs = event.currentMs;

    if (s is! LoadedKaraoke) return;
    if (!s.isPlaying) {
      _lastMs = currentTimeMs;
      emit(s.copyWith(currentTimeMs: currentTimeMs));
      return;
    }

    int delta = currentTimeMs - _lastMs;
    if (delta <= 0 || delta > 200) delta = 50; // xử lý trường hợp lỗi
    _lastMs = currentTimeMs;
    if (s.song.notes.isNotEmpty) {
      final lastNote = s.song.notes.last;
      final endMs = lastNote.startMs + lastNote.durationMs;
      if (currentTimeMs >= endMs) {
        _isComplete = true;
        add(CompleteKaraoke());
        return;
      }
    }

    int newTotalHitMs = s.totalHitMs;
    final updatedHitDurations = Map<int, double>.from(s.hitDuration);
    final updateHitMs = Map<int, int>.from(s.hitMs);
    bool foundNote = false;
    // Binary search
    if (_latestPitch > 50) {
      final userMidi = 69.0 + 12.0 * (log(_latestPitch / 440.0) / ln2);
      final notes = s.song.notes;

      int lo = 0, hi = notes.length - 1;
      while (lo <= hi) {
        final mid = (lo + hi) >> 1;
        final note = notes[mid];
        if (currentTimeMs < note.startMs) {
          hi = mid - 1;
        } else if (currentTimeMs > note.startMs + note.durationMs) {
          lo = mid + 1;
        } else {
          if ((userMidi - note.midiPitch).abs() <= 0.4) {
            foundNote = true;
            if (_lastHitNoteStartMs != note.startMs) {
              updateHitMs[note.startMs] = currentTimeMs;
              _lastHitNoteStartMs = note.startMs;
            }
            newTotalHitMs += delta;
            updatedHitDurations[note.startMs] =
                (updatedHitDurations[note.startMs] ?? 0.0) + delta;
          }
          break;
        }
      }
    }
    if (!foundNote) {
      _lastHitNoteStartMs = null;
    }
    emit(
      s.copyWith(
        currentTimeMs: currentTimeMs,
        totalHitMs: newTotalHitMs,
        hitDuration: updatedHitDurations,
        hitMs: updateHitMs
      ),
    );
  }

  Future<void> _onPauseKaraoke(PauseKaraoke event, Emitter emit) async {
    final s = state;
    if (s is LoadedKaraoke) {
      emit(s.copyWith(isPlaying: false));
      karaokeAudioRepository.pause();
      _lastMs = s.currentTimeMs;
    }
  }

  Future<void> _onResumeKaraoke(ResumeKaraoke event, Emitter emit) async {
    final s = state;
    if (s is LoadedKaraoke) {
      karaokeAudioRepository.resume();
      _lastMs = s.currentTimeMs;
      emit(s.copyWith(isPlaying: true));
    }
  }

  Future<void> _onCompleteKaraoke(CompleteKaraoke event, Emitter emit) async {
    final s = state;
    if (s is! LoadedKaraoke) return;
    _isComplete = true;
    await karaokeAudioRepository.stop();
    final totalNoteMs = s.song.notes.fold<int>(0, (sum, n) => sum + n.durationMs);
    final score = totalNoteMs > 0 ? ((s.totalHitMs / totalNoteMs) * 100).clamp(0, 100).round() : 0;
    emit(CompletedKaraoke(score));
  }

  @override
  Future<void> close() {
    _completeSub.cancel();
    return super.close();
  }
}