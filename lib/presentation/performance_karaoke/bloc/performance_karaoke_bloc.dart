import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/karaoke/kar_parse.dart';
import 'package:ikara_clone/data/model/performances/kar_song.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';

import '../../../data/repositories/karaoke_audio_repository.dart';

part 'performance_karaoke_event.dart';
part 'performance_karaoke_state.dart';

class PerformanceKaraokeBloc
    extends Bloc<PerformanceKaraokeEvent, PerformanceKaraokeState> {
  final PerformanceRepository repository;
  final KaraokeAudioRepository karaokeAudioRepository;
  final Dio dio;
  StreamSubscription? _pitchSubscription;
  StreamSubscription? _playbackSubscription;

  PerformanceKaraokeBloc({
    required this.repository,
    required this.dio,
    required this.karaokeAudioRepository,
  }) : super(InitialKaraoke()) {
    on<LoadPerformance>(_onLoadPerformance);
    on<UpdatePlaybackTime>(_onUpdatePlaybackTime);
    on<UpdateUserPitch>(_onUpdateUserPitch);
    on<PauseKaraoke>(_onPauseKaraoke);
    on<ResumeKaraoke>(_onResumeKaraoke);
  }

  void _startSubscriptions() {
    DateTime lastPitchTime = DateTime.now();
    double lastPitch = 0.0;

    _playbackSubscription = karaokeAudioRepository.playbackProgressStream.listen((ms) {
      if (!isClosed) add(UpdatePlaybackTime(ms));
    });

    _pitchSubscription = karaokeAudioRepository.pitchStream.listen((pitchHz) {
      if (isClosed) return;

      final now = DateTime.now();
      final currentState = state;
      if (currentState is! LoadedKaraoke) return;

      if (now.difference(lastPitchTime).inMilliseconds > 50 ||
          (pitchHz - lastPitch).abs() > 1.0) {
        lastPitchTime = now;
        lastPitch = pitchHz;
        add(UpdateUserPitch(pitchHz));
      }
    });
  }

  Future<void> _onLoadPerformance(LoadPerformance event, Emitter emit) async {
    await _pitchSubscription?.cancel();
    await _playbackSubscription?.cancel();
    emit(LoadingKaraoke());
    try {
      final lesson = await repository.getDetailPerformance(event.id);
      final response = await dio.get(
        lesson.midiLink,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        final Uint8List midiBytes = Uint8List.fromList(
          response.data as List<int>,
        );
        final parse = KarParser();
        final song = parse.parse(midiBytes);
        emit(LoadedKaraoke(lesson: lesson, song: song));
        await karaokeAudioRepository.start(lesson.karaokeLink);
        if (isClosed) return;
        _startSubscriptions();
      } else {
        throw Exception("Không thể tải nhạc. Mã lỗi ${response.statusCode}");
      }
    } on DioException catch (e) {
      emit(ErrorKaraoke('Lỗi kết nối mạng ${e.message}'));
    } catch (e) {
      emit(ErrorKaraoke(e.toString()));
    }
  }

  void _onUpdatePlaybackTime(UpdatePlaybackTime event, Emitter emit) {
    final currentState = state;
    if (currentState is LoadedKaraoke) {
      emit(currentState.copyWith(currentMs: event.currentMs));
    }
  }

  void _onUpdateUserPitch(UpdateUserPitch event, Emitter emit) {
    final currentState = state;
    if (currentState is LoadedKaraoke) {
      emit(currentState.copyWith(userPitchHz: event.pitchHz));
    }
  }

  void _onPauseKaraoke(PauseKaraoke event, Emitter emit) {
    final s = state;
    if (s is LoadedKaraoke) {
      karaokeAudioRepository.pause();
      emit(s.copyWith(isPlaying: false));
    }
  }

  void _onResumeKaraoke(ResumeKaraoke event, Emitter emit) {
    final s = state;
    if (s is LoadedKaraoke) {
      karaokeAudioRepository.resume();
      emit(s.copyWith(isPlaying: true));
    }
  }

  @override
  Future<void> close() async {
    await _pitchSubscription?.cancel();
    await _playbackSubscription?.cancel();
    _pitchSubscription = null;
    _playbackSubscription = null;
    await karaokeAudioRepository.stop();
    return super.close();
  }
}