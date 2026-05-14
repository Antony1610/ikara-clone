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
  final KaraokeAudioRepository karaokeAudioRepository; // ✅ abstract
  final Dio dio;
  StreamSubscription? _pitchSubscription;
  StreamSubscription? _playbackSubscription;

  PerformanceKaraokeBloc({
    required this.repository,
    required this.dio,
    required this.karaokeAudioRepository, // ✅
  }) : super(InitialKaraoke()) {
    // ⚠️ Stream subscription nên trong handler, không phải constructor
    // Nhưng giữ nguyên pattern này nếu project đang dùng
    _playbackSubscription = karaokeAudioRepository.playbackProgressStream.listen((ms) {
      add(UpdatePlaybackTime(ms));
    });

    _pitchSubscription = karaokeAudioRepository.pitchStream.listen((pitchHz) {
      add(UpdateUserPitch(pitchHz));
    });

    on<LoadPerformance>(_onLoadPerformance);
    on<UpdatePlaybackTime>(_onUpdatePlaybackTime);
    on<UpdateUserPitch>(_onUpdateUserPitch);
    on<PauseKaraoke>(_onPauseKaraoke);
    on<ResumeKaraoke>(_onResumeKaraoke);
  }

  Future<void> _onLoadPerformance(LoadPerformance event, Emitter emit) async {
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
        await karaokeAudioRepository.start(lesson.karaokeLink); // ✅
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
      karaokeAudioRepository.pause(); // ✅ gọi pause thật sự
      emit(s.copyWith(isPlaying: false));
    }
  }

  void _onResumeKaraoke(ResumeKaraoke event, Emitter emit) {
    final s = state;
    if (s is LoadedKaraoke) {
      karaokeAudioRepository.resume(); // ✅ gọi resume thật sự
      emit(s.copyWith(isPlaying: true));
    }
  }

  @override
  Future<void> close() async {
    await _pitchSubscription?.cancel();
    await _playbackSubscription?.cancel();
    await karaokeAudioRepository.stop(); // ✅
    return super.close();
  }
}