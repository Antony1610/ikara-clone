import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
part 'rhythm_training_event.dart';
part 'rhythm_training_state.dart';

class RhythmTrainingBloc
    extends Bloc<RhythmTrainingEvent, RhythmTrainingState> {
  final RhythmsRepository _rhythmsRepository;
  RhythmTrainingBloc(this._rhythmsRepository) : super(RhythmInitial()) {
    on<RhythmLoad>(_onRhythmLoad);
  }

  Future<void> _onRhythmLoad(RhythmLoad event, Emitter emit) async {
    emit(RhythmLoading());
    try {
      final parts = await _rhythmsRepository.getRhythmsList();
      emit(RhythmLoaded(parts));
    } on NetworkException catch (e) {
      emit(RhythmError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(RhythmError(e.message));
    } catch (e) {
      emit(RhythmError(e.toString()));
    }
  }
}
