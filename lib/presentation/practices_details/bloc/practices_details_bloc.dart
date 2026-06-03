import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/model/practices/midi_note_practices.dart';
import 'package:ikara_clone/data/model/user/practices_user_result.dart';
import 'package:ikara_clone/data/repositories/practices_audio_repository.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'practices_details_event.dart';
part 'practices_details_state.dart';

class PracticesDetailsBloc
    extends Bloc<PracticesDetailsEvent, PracticesDetailsState> {
  final PracticesRepository _practicesRepository;
  final PracticesAudioRepository _audioRepository;
  final String uid;
  final UserRepository _userRepository;
  StreamSubscription? _positionSub;
  StreamSubscription? _pitchSub;
  StreamSubscription? _completeSub;
  double _latestPitch = 0.0;
  int _lastMs = 0;
  bool _isComplete = false;
  PracticesDetailsBloc(
    this._practicesRepository,
    this._audioRepository,
    this._userRepository,
    this.uid,
  ) : super(InitialPractices()) {
    on<LoadPractices>(_onLoadPractices);
    on<PlayPractices>(_onPlayPractices);
    on<PausePractices>(_onPausePractices);
    on<ResumePractices>(_onResumePractices);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdatePitch>(_onUpdatePitch);
    on<CompletePractices>(_onCompletePractices);
  }

  Future<void> _onLoadPractices(LoadPractices event, Emitter emit) async {
    emit(LoadingPractices());
    try {
      await _cancelSubscription();
      await _audioRepository.stop();
      final practices = await _practicesRepository.getPractices(event.id);
      final notes = await _practicesRepository.getMidiNotes(
        'assets/assets_data/Archive/${practices!.midiUrl}',
      );
      await _audioRepository.load(practices.mp3Url);
      _isComplete = false;
      emit(
        LoadedPractices(
          notes: notes,
          practices: practices,
          userPitchHz: 0.0,
          totalHitMs: 0,
          lastTickMs: 0,
          isPlaying: false,
          hasStarted: false,
          showOverlay: false,
          hitDuration: const {},
        ),
      );
    } catch (e) {
      emit(ErrorPractices(e.toString()));
    }
  }

  void _onPlayPractices(PlayPractices event, Emitter emit) async {
    final s = state;
    if (s is! LoadedPractices) return;
    if (s.isPlaying) return;

    if (s.hasStarted) {
      _audioRepository.resume();
      emit(s.copyWith(isPlaying: true));
      return;
    }

    _audioRepository.start();
    await _waitUntilPlaying();
    _startCombinedSubscription();

    emit(s.copyWith(isPlaying: true, hasStarted: true, showOverlay: false));
  }

  void _startCombinedSubscription() {
    _positionSub = _audioRepository.positionStream.listen((position) {
      add(UpdatePosition(position.inMilliseconds));
    });

    _pitchSub = _audioRepository.pitchStream.listen((pitch) {
      add(UpdatePitch(pitch));
    });

    _completeSub = _audioRepository.completeStream.listen((_) {
      add(CompletePractices());
    });
  }

  Future<void> _waitUntilPlaying() async {
    await for (final pos in _audioRepository.positionStream) {
      if (pos.inMilliseconds > 0) {
        break;
      }
    }
  }
  Future<void> _onResumePractices(ResumePractices event, Emitter emit) async {
    final s = state;
    if (s is! LoadedPractices) return;
    emit(s.copyWith(isPlaying: false, hasStarted: true, showOverlay: false));
  }

  Future<void> _onPausePractices(PausePractices event, Emitter emit) async {
    final s = state;
    if (s is LoadedPractices) {
      _audioRepository.pause();
      emit(s.copyWith(isPlaying: false, showOverlay: true));
    }
  }

  void _onUpdatePitch(UpdatePitch event, Emitter emit) {
    if (_isComplete) return;
    _latestPitch = event.userPitchHz;
    final s = state;
    if (s is! LoadedPractices) return;
    if (!s.isPlaying) return;
    debugPrint('UserPitchHz: $_latestPitch');
    emit(s.copyWith(userPitchHz: _latestPitch));
  }

  void _onUpdatePosition(UpdatePosition event, Emitter emit) {
    if (_isComplete) return;

    final s = state;
    if (s is! LoadedPractices) return;
    if (!s.isPlaying) return;
    final currentTimeMs = event.currentMs;

    int delta = currentTimeMs - _lastMs;
    if (delta <= 0 || delta > 200) delta = 50; // xử lý trường hợp lỗi
    _lastMs = currentTimeMs;
    if (s.notes.isNotEmpty) {
      final lastNote = s.notes.last;
      final endMs = lastNote.startMs + lastNote.durationMs;
      if (currentTimeMs >= endMs) {
        _isComplete = true;
        add(CompletePractices());
        return;
      }
    }

    int newTotalHitMs = s.totalHitMs;
    final updatedHitDurations = Map<int, double>.from(s.hitDuration);

    // Binary search
    if (_latestPitch > 50) {
      final userMidi = 69.0 + 12.0 * (log(_latestPitch / 440.0) / ln2);
      final notes = s.notes;

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
            newTotalHitMs += delta;
            updatedHitDurations[note.startMs] =
                (updatedHitDurations[note.startMs] ?? 0.0) + delta;
          }
          break;
        }
      }
    }

    emit(
      s.copyWith(
        currentTimeMs: currentTimeMs,
        totalHitMs: newTotalHitMs,
        lastTickMs: currentTimeMs,
        hitDuration: updatedHitDurations,
      ),
    );
  }

  Future<void> _onCompletePractices(
    CompletePractices event,
    Emitter emit,
  ) async {
    final s = state;
    if (s is! LoadedPractices) return;
    _isComplete = true;
    await _cancelSubscription();
    await _audioRepository.stop();

    final totalNoteMs = s.notes.fold<int>(0, (sum, n) => sum + n.durationMs);
    final score = totalNoteMs > 0
        ? ((s.totalHitMs / totalNoteMs) * 100).clamp(0, 100).round()
        : 0;
    final practices = s.practices;

    emit(
      FinishedPractices(
        score: score,
        practicesPart: practices,
        status: 'READY',
      ),
    );

    final userResult = PracticesUserResult(
      id: practices.id,
      name: practices.name,
      description: practices.description,
      score: score,
      image: practices.image,
      midiUrl: practices.midiUrl,
      mp3Url: practices.mp3Url,
      status: 'READY',
    );
    await _userRepository.updateUserPractices(uid, userResult);
  }

  Future<void> _cancelSubscription() async {
    await _positionSub?.cancel();
    await _pitchSub?.cancel();
    await _completeSub?.cancel();
    _positionSub = null;
    _pitchSub = null;
    _completeSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    await _audioRepository.stop();
    return super.close();
  }
}

