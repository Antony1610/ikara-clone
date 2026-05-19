import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/breaths/breaths.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'breathing_event.dart';
part 'breathing_state.dart';

class BreathingBloc extends Bloc<BreathingEvent, BreathingState> {
  final BreathsRepository _breathsRepository;
  final String uid;
  final UserRepository _userRepository;
  BreathingBloc(this._breathsRepository, this.uid, this._userRepository)
    : super(BreathingInitial()) {
    on<BreathingPartLoad>(_onPartsLoaded);
  }
  Future<void> _onPartsLoaded(BreathingPartLoad event, Emitter emit) async {
    emit(BreathingLoading());
    try {
      final parts = await _breathsRepository.getParts();
      final userResult = await _userRepository.getListBreathsResult(uid);
      final scoreMap = {for (final r in userResult) r.id: r.score};
      emit(
        PartsLoaded(parts, {
          for (final part in parts) part.id: _calcStar(scoreMap[part.id] ?? 0),
        }),
      );
    } on NetworkException catch (e) {
      emit(BreathingError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(BreathingError(e.message));
    } catch (e) {
      emit(BreathingError(e.toString()));
    }
  }

  int _calcStar(int score) {
    if (score >= 90) return 3;
    if (score >= 60) return 2;
    if (score >= 30) return 1;
    return 0;
  }
}
