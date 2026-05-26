import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';

part 'practices_results_event.dart';
part 'practices_results_state.dart';


class PracticesResultsBloc extends Bloc<PracticesResultsEvent, PracticesResultsState>{
  PracticesResultsBloc() : super(InitialResult()) {
    on<LoadPracticesResult>(_onLoadPracticesResult);
  }

  void _onLoadPracticesResult(LoadPracticesResult event, Emitter emit) {
    emit(LoadingResult());
    try {
      final stars = _calStart(event.score);
      emit(LoadedResult(score: event.score, practicesPart: event.practicesPart, status: event.status, feedbackText: _feedbackText(stars), stars: stars, isPass: stars >= 1));
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