import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
part 'performance_detail_event.dart';
part 'performance_detail_state.dart';

class PerformanceDetailBloc
    extends Bloc<PerformanceDetailEvent, PerformanceDetailState> {
  final PerformanceRepository _performanceRepository;
  PerformanceDetailBloc(this._performanceRepository)
    : super(PerformanceDetailInitial()) {
    on<LoadPerformanceDetail>(_onLoadPerformanceDetail);
    on<VideoPlayPauseToggled>(_onVideoPlayPauseToggled);
    on<VideoPositionChanged>(_onVideoPositionChanged);
  }

  Future<void> _onLoadPerformanceDetail(
    LoadPerformanceDetail event,
    Emitter emit,
  ) async {
    emit(PerformanceDetailLoading());
    try {
      final selectedPerformance = await _performanceRepository
          .getDetailPerformance(event.id);
      emit(PerformanceDetailLoaded(lesson: selectedPerformance));
    } on AppException catch (e) {
      emit(PerformanceDetailError(e.message));
    } catch (e) {
      emit(PerformanceDetailError(e.toString()));
    }
  }

  void _onVideoPlayPauseToggled(VideoPlayPauseToggled event, Emitter emit) {
    final current = state;
    if (current is! PerformanceDetailLoaded) return;
    emit(current.copyWith(isVideoPlaying: !current.isVideoPlaying));
  }

  void _onVideoPositionChanged(
      VideoPositionChanged event,
      Emitter emit,
      ) {
    final current = state;
    if (current is! PerformanceDetailLoaded) return;

    emit(
      current.copyWith(
        currentPosition: event.position,
      ),
    );
  }
}
