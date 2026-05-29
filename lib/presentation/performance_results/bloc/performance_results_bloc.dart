import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
part 'performance_results_state.dart';
part 'performance_results_event.dart';

class PerformanceResultsBloc extends Bloc<PerformanceResultsEvent, PerformanceResultsState>{
  PerformanceResultsBloc() : super(InitialResult()) {
    on<LoadPerformanceResult>(_onLoadPerformanceResult);
  }

  void _onLoadPerformanceResult(LoadPerformanceResult event, Emitter emit) {
    emit(LoadingResult());
    try {
      final stars = _calStart(event.score);
      emit(LoadedResult(score: event.score, feedbackText: _feedbackText(stars), stars: stars));
    } catch (e) {
      emit(ErrorResult(e.toString()));
    }
  }

  int _calStart(int score) {
    if (score >= 80) return 3;
    if (score >= 50) return 2;
    if (score >= 20) return 1;
    return 0;
  }

  String _feedbackText(int stars) => switch (stars) {
    1 => 'Bạn cần cố gắng để cải thiện tốt hơn',
    2 => 'Khá tốt - tiếp tục luyện tập để hoàn thiện thêm',
    3 => 'Xuất sắc - giữ vững phong độ nhé!',
    _ => 'Bạn cần cố gắng để cải thiện tốt hơn'
  };
}