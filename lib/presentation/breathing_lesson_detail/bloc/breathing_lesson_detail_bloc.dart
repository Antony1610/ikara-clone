import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/model/breaths/breaths.dart';
import 'package:ikara_clone/data/model/user/breath_user_result.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';

import '../../../data/repositories/audio_repository.dart';

part 'breathing_lesson_detail_event.dart';
part 'breathing_lesson_detail_state.dart';

class BreathingLessonDetailBloc
    extends Bloc<BreathingLessonDetailEvent, BreathingLessonDetailState> {
  final AudioRepository _audioRepository;
  final BreathsRepository _repository;
  final String uid;
  final UserRepository _userRepository;
  StreamSubscription<int>? _resultSubscription;
  Timer? _timer;

  bool _isStopping = false;
  int _invalidFrameCount = 0;
  bool _isBreathingValidNow = false;
  bool _hasStartedBlowing = false;
  double _validSeconds = 0.0;
  int _validFrameCount = 0;
  static const int _requiredStableFrames = 10;
  static const int _requiredInvalidFrames = 15;

  BreathingLessonDetailBloc({
    required BreathsRepository repository,
    required AudioRepository audioRepository,
    required this.uid,
    required UserRepository userRepository,
  }) : _repository = repository,
        _audioRepository = audioRepository,
  _userRepository = userRepository,
        super(DetailInitial()) {
    on<InitBreathing>(_onInit);
    on<StartBreathing>(_onStartBreathing);
    on<StopBreathing>(_onStopBreathing);
    on<UpdateVolume>(_onUpdateVolume);
    on<TimerTicked>(_onTimerTicked);
  }

  Future<void> _onInit(InitBreathing event, Emitter emit) async {
    try {
      emit(DetailLoading());
      final breathDetail = await _repository.getDetailParts(event.id);
      await _audioRepository.init();
      emit(
        DetailLoaded(
          breathsPart: breathDetail,
          targetDuration: breathDetail.duration.inSeconds.toDouble(),
        ),
      );
    } catch (e) {
      emit(DetailError(e.toString()));
    }
  }

  Future<void> _onStartBreathing(StartBreathing event, Emitter emit) async {
    if (state is! DetailLoaded) return;
    final currentState = state as DetailLoaded;

    if (currentState.isRecording) return;

    _isStopping = false;
    _hasStartedBlowing = false;
    _validSeconds = 0;
    _validFrameCount = 0;
    _isBreathingValidNow = false;

    emit(
      currentState.copyWith(
        isRecording: true,
        elapsedSeconds: 0,
        currentVolumeLevel: 0,
        score: 0,
      ),
    );

    await _audioRepository.startRecording();

    _resultSubscription?.cancel();
    _resultSubscription = _audioRepository.volumeStream.listen((sample) {
      add(UpdateVolume(sample));
    });
  }

  void _startTimer() {
    _timer?.cancel();
    double elapsed = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      elapsed += 0.1;
      add(TimerTicked(elapsed));
    });
  }

  Future<void> _onStopBreathing(StopBreathing event, Emitter emit) async {
    if (_isStopping) return;
    _isStopping = true;

    _timer?.cancel();
    _resultSubscription?.cancel();

    await _audioRepository.stopRecording();

    if (state is! DetailLoaded) return;
    final currentState = state as DetailLoaded;

    if (event.isCompleted) {
      emit(
        DetailCompleted(
          id: currentState.breathsPart.partId,
          score: currentState.score,
          type: currentState.breathsPart.type,
          duration: currentState.targetDuration,
        ),
      );
      _userRepository.updateUserBreaths(uid, BreathUserResult(id: currentState.breathsPart.id, score: currentState.score));
    } else {
      emit(
        currentState.copyWith(
          isRecording: false,
          currentVolumeLevel: 0,
          elapsedSeconds: 0,
          score: 0,
        ),
      );
    }
  }

  void _onUpdateVolume(UpdateVolume event, Emitter emit) {
    if (_isStopping) return;
    if (state is! DetailLoaded) return;
    final currentState = state as DetailLoaded;
    if (!currentState.isRecording) return;

    if (_isValidBreath(event.sample)) {
      _validFrameCount++;
      _invalidFrameCount = 0;
    } else {
      _invalidFrameCount++;
      _validFrameCount = 0;
    }

    _isBreathingValidNow = _validFrameCount >= _requiredStableFrames;

    if (!_hasStartedBlowing && _isBreathingValidNow) {
      _hasStartedBlowing = true;
      _startTimer();
    }

    if (_hasStartedBlowing && _invalidFrameCount >= _requiredInvalidFrames) {
      add(StopBreathing(isCompleted: true));
      return;
    }

    emit(currentState.copyWith(currentVolumeLevel: event.sample));
  }

  void _onTimerTicked(TimerTicked event, Emitter emit) {
    if (state is! DetailLoaded) return;
    final currentState = state as DetailLoaded;

    if (_isBreathingValidNow) _validSeconds += 0.1;

    final int score = currentState.targetDuration > 0
        ? ((_validSeconds / currentState.targetDuration) * 100).round().clamp(0, 100)
        : 0;

    if (event.elapsedSeconds >= currentState.targetDuration) {
      _timer?.cancel();
      emit(currentState.copyWith(
        elapsedSeconds: currentState.targetDuration,
        score: score,
      ));
    } else {
      emit(currentState.copyWith(
        elapsedSeconds: event.elapsedSeconds,
        score: score,
      ));
    }
  }

  bool _isValidBreath(int sample) => sample >= 32767 / 7;

  @override
  Future<void> close() {
    _resultSubscription?.cancel();
    _timer?.cancel();
    _audioRepository.dispose();
    return super.close();
  }
}