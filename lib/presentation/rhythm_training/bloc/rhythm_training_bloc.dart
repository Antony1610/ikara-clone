import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'rhythm_training_event.dart';
part 'rhythm_training_state.dart';

class RhythmTrainingBloc
    extends Bloc<RhythmTrainingEvent, RhythmTrainingState> {
  final RhythmsRepository _rhythmsRepository;
  final String uid;
  final UserRepository _userRepository;
  RhythmTrainingBloc(this._rhythmsRepository, this.uid, this._userRepository)
    : super(RhythmInitial()) {
    on<RhythmLoad>(_onRhythmLoad);
  }

  Future<void> _onRhythmLoad(RhythmLoad event, Emitter emit) async {
    emit(RhythmLoading());
    try {
      final parts = await _rhythmsRepository.getRhythmsList();
      final userResult = await _userRepository.getListRhythmsResult(uid);
      final scoreMap = {for (final r in userResult) r.id: r.score};
      emit(
        RhythmLoaded(parts, {
          for (final part in parts) part.id: _calcStar(scoreMap[part.id] ?? 0),
        }),
      );
    } on NetworkException catch (e) {
      emit(RhythmError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(RhythmError(e.message));
    } catch (e) {
      emit(RhythmError(e.toString()));
    }
  }

  int _calcStar(int score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }
}
