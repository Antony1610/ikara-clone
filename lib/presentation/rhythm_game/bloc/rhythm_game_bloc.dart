import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/rhythms/rhythms.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/constants/constants.dart';

part 'rhythm_game_event.dart';
part 'rhythm_game_state.dart';

class RhythmGameBloc extends Bloc<RhythmGameEvent, RhythmGameState> {
  final RhythmsRepository _rhythmsRepository;

  final int bpm = 60;
  late final double msPerBeat;

  RhythmGameBloc(this._rhythmsRepository) : super(RhythmGameInitial()) {
    msPerBeat = (60 / bpm) * 1000;

    on<LoadGame>(_onLoadGame);
    on<StartGame>(_onStartGame);
    on<StopGame>(_onStopGame);
    on<UpdateTick>(_onUpdateTick);
    on<Tap>(_onTap);
    on<FinishedGame>(_onFinishedGame);
  }

  Future<void> _onLoadGame(LoadGame event, Emitter emit) async {
    emit(RhythmGameLoading());

    try {
      final part = await _rhythmsRepository.getRhythmsById(event.partId);

      if (part == null) {
        emit(RhythmGameError('Không tìm thấy'));
        return;
      }

      List<Note> parsedNotes = [];
      int noteId = 0;
      int absoluteBeatIndex = 0;

      for (int mIndex = 0; mIndex < part.measures.length; mIndex++) {
        final beats = part.measures[mIndex];

        for (int bIndex = 0; bIndex < beats.length; bIndex++) {
          final beatType = beats[bIndex];

          final type = beatType == BeatType.beat
              ? NoteType.beat
              : NoteType.rest;

          final time = (absoluteBeatIndex * msPerBeat).round();

          parsedNotes.add(
            Note(id: noteId++, type: type, timeMs: time, measure: mIndex + 1),
          );

          absoluteBeatIndex++;
        }
      }

      emit(
        RhythmGameLoaded(
          partId: event.partId,
          notes: parsedNotes,
          title: part.title,
          currentTimeMs: -2000,
          feedbackText: 'Sẵn sàng',
          isPlaying: false,
        ),
      );
    } on AppException catch (e) {
      emit(RhythmGameError(e.message));
    } catch (e) {
      emit(RhythmGameError(e.toString()));
    }
  }

  void _onStartGame(StartGame event, Emitter emit) {
    if (state is! RhythmGameLoaded) return;

    final s = state as RhythmGameLoaded;

    final firstBeat = s.notes.firstWhere(
          (n) => n.type == NoteType.beat,
      orElse: () => s.notes.first,
    );

    emit(
      s.copyWith(
        isPlaying: true,
        tappedNote: [],
        currentTimeMs: firstBeat.timeMs,
        feedbackText: '',
        justStarted: true,
        notes: s.notes.map((n) => n.copyWith(status: HitStatus.none)).toList(),
      ),
    );
  }

  void _onStopGame(StopGame event, Emitter emit) {
    if (state is RhythmGameLoaded) {
      emit((state as RhythmGameLoaded).copyWith(isPlaying: false));
    }
  }

  void _onUpdateTick(UpdateTick event, Emitter emit) {
    if (state is! RhythmGameLoaded) return;

    final currentState = state as RhythmGameLoaded;
    if (!currentState.isPlaying) return;

    if (currentState.justStarted) {
      emit(currentState.copyWith(justStarted: false));
      return;
    }

    final newTimeMs = currentState.currentTimeMs + event.deltaMs;

    List<Note> updateNotes = List.from(currentState.notes);

    // ✅ Khai báo ở đây để add miss vào tappedNote
    final List<TappedNote> updatedTappedNotes = List.from(currentState.tappedNote);

    String newFeedback = currentState.feedbackText;
    bool hasUpdate = false;

    for (int i = 0; i < updateNotes.length; i++) {
      final note = updateNotes[i];

      if (note.status == HitStatus.none && note.type == NoteType.beat) {
        final delta = newTimeMs - note.timeMs;

        if (delta > 200) {
          final newNote = note.copyWith(status: HitStatus.miss);
          updateNotes[i] = newNote;

          final tapped = TappedNote(timeMs: newTimeMs, status: HitStatus.miss);

          // ✅ Add miss vào tappedNote để _onFinishedGame đếm được
          updatedTappedNotes.add(tapped);

          newFeedback = tapped.feedbackText;
          hasUpdate = true;
        }
      }
    }

    final allDone = updateNotes
        .where((n) => n.type == NoteType.beat)
        .every((n) => n.status != HitStatus.none);

    final lastBeatTime = updateNotes
        .where((n) => n.type == NoteType.beat)
        .map((n) => n.timeMs)
        .reduce((a, b) => a > b ? a : b);

    final pastEnd = newTimeMs > lastBeatTime + 500;

    if (allDone && pastEnd) {
      emit(
        currentState.copyWith(
          notes: updateNotes,
          currentTimeMs: newTimeMs,
          isPlaying: false,
          feedbackText: 'Hoàn thành!',
          tappedNote: updatedTappedNotes,
        ),
      );
      add(FinishedGame(currentState.partId));
      return;
    }

    emit(
      currentState.copyWith(
        notes: hasUpdate ? updateNotes : currentState.notes,
        currentTimeMs: newTimeMs,
        feedbackText: hasUpdate ? newFeedback : currentState.feedbackText,
        tappedNote: hasUpdate ? updatedTappedNotes : currentState.tappedNote,
        tapCount: hasUpdate ? currentState.tapCount + 1 : currentState.tapCount
      ),
    );
  }

  void _onTap(Tap event, Emitter emit) {
    if (state is! RhythmGameLoaded) return;

    final currentState = state as RhythmGameLoaded;
    if (!currentState.isPlaying) return;

    List<Note> updateNotes = List.from(currentState.notes);

    Note? targetNote;
    int minDelta = 9999;

    for (var note in updateNotes) {
      final delta = currentState.currentTimeMs - note.timeMs;

      if (delta >= -200 && delta <= 200) {
        if (delta.abs() < minDelta.abs()) {
          minDelta = delta;
          targetNote = note;
        }
      }
    }

    final List<TappedNote> updatedTappedNotes = List.from(
      currentState.tappedNote,
    );
    String currentFeedback = currentState.feedbackText;

    if (targetNote != null) {
      final idx = updateNotes.indexWhere((n) => n.id == targetNote!.id);
      HitStatus newStatus;

      if (targetNote.type == NoteType.rest) {
        newStatus = HitStatus.rest;
      } else if (minDelta.abs() <= 50) {
        newStatus = HitStatus.perfect;
      } else if (minDelta < 0) {
        newStatus = HitStatus.early;
      } else if (minDelta <= 200) {
        newStatus = HitStatus.late;
      } else {
        newStatus = HitStatus.miss;
      }

      updateNotes[idx] = targetNote.copyWith(
        status: newStatus,
        isHighlighted:
        newStatus == HitStatus.perfect || newStatus == HitStatus.miss,
      );

      final tapped = TappedNote(
        timeMs: currentState.currentTimeMs,
        status: newStatus,
      );

      currentFeedback = tapped.feedbackText;

      if (targetNote.type != NoteType.rest) {
        updatedTappedNotes.add(tapped);
      }
    } else {
      final candidates = updateNotes
          .where((n) => n.status == HitStatus.none)
          .toList();


      if (candidates.isEmpty) {
        final tapped = TappedNote(
          timeMs: currentState.currentTimeMs,
          status: HitStatus.miss,
        );
        updatedTappedNotes.add(tapped);
        currentFeedback = tapped.feedbackText;

        emit(
          currentState.copyWith(
            feedbackText: currentFeedback,
            tappedNote: updatedTappedNotes,
          ),
        );
        return;
      }

      candidates.sort(
            (a, b) => (a.timeMs - currentState.currentTimeMs).abs().compareTo(
          (b.timeMs - currentState.currentTimeMs).abs(),
        ),
      );

      final nearest = candidates.first;
      final delta = currentState.currentTimeMs - nearest.timeMs;

      HitStatus status;

      if (nearest.type == NoteType.rest) {
        status = HitStatus.rest;
      } else if (delta.abs() <= 50) {
        status = HitStatus.perfect;
      } else if (delta < 0) {
        status = HitStatus.early;
      } else {
        status = HitStatus.late;
      }

      final tapped = TappedNote(
        timeMs: currentState.currentTimeMs,
        status: status,
      );

      updatedTappedNotes.add(tapped);
      currentFeedback = tapped.feedbackText;
    }

    emit(
      currentState.copyWith(
        notes: updateNotes,
        feedbackText: currentFeedback,
        tappedNote: updatedTappedNotes,
        tapCount: currentState.tapCount + 1
      ),
    );
  }

  void _onFinishedGame(FinishedGame event, Emitter emit) {
    if (state is! RhythmGameLoaded) return;
    final current = state as RhythmGameLoaded;

    // Tổng số beat thực tế trong bài
    final totalBeats = current.notes
        .where((n) => n.type == NoteType.beat)
        .length;

    if (totalBeats == 0) {
      emit(
        RhythmGameCompleted(
          RhythmsResult(
            score: 0,
            perfect: 0,
            miss: 0,
            late: 0,
            early: 0,
            rhythmId: event.partId,
          ),
        ),
      );
      return;
    }

    int perfect = 0;
    int late = 0;
    int early = 0;
    int missed = 0;

    for (final note in current.tappedNote) {
      switch (note.status) {
        case HitStatus.perfect:
          perfect++;
          break;
        case HitStatus.early:
          early++;
          break;
        case HitStatus.late:
          late++;
          break;
        case HitStatus.miss:
          missed++;
          break;
        default:
          break;
      }
    }

    final total = perfect + early + late + missed;

    // Tap thừa = tổng tap vượt quá số beat thực tế → phạt 1.0 điểm mỗi tap
    final extraTaps = (total - totalBeats).clamp(0, total);

    double rawScore = (perfect * 1.0)
        + (early * 0.7)
        + (late * 0.7)
        - (missed * 0.3)
        - (extraTaps * 1.0);

    rawScore = rawScore.clamp(0, double.infinity);
    final score = ((rawScore / totalBeats) * 100).clamp(0, 100).round();

    emit(
      RhythmGameCompleted(
        RhythmsResult(
          rhythmId: event.partId,
          score: score,
          perfect: perfect,
          late: late,
          early: early,
          miss: missed,
        ),
      ),
    );
  }
}