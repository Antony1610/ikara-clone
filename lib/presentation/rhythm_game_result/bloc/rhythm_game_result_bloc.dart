import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/model/model.dart';
part 'rhythm_game_result_event.dart';
part 'rhythm_game_result_state.dart';

class RhythmGameResultBloc
    extends Bloc<RhythmGameResultEvent, RhythmGameResultState> {
  RhythmGameResultBloc() : super(RhythmGameResultInitial()) {
    on<LoadResultEvent>(_onLoadResultEvent);
  }

  void _onLoadResultEvent(LoadResultEvent event, Emitter emit) {
    final result = event.result;

    int score = result.score;
    int starCount = 0;

    if (score >= 90) {
      starCount = 3;
    } else if (score >= 70) {
      starCount = 2;
    } else if (score >= 50) {
      starCount = 1;
    } else {
      starCount = 0;
    }

    bool isPassed = starCount >= 1;
    String feedbackMessage = isPassed
        ? "Làm tốt lắm"
        : "Cố lên! Bạn có thể làm tốt hơn";
    emit(
      RhythmGameResultLoaded(
        result: result,
        starCount: starCount,
        feedbackMessage: feedbackMessage,
        isPassed: isPassed,
      ),
    );
  }
}
