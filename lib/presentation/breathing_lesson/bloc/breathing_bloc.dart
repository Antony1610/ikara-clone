import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/breaths/breaths.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
part 'breathing_event.dart';
part 'breathing_state.dart';

class BreathingBloc extends Bloc<BreathingEvent, BreathingState> {
  final BreathsRepository _breathsRepository;
  BreathingBloc(this._breathsRepository) : super(BreathingInitial()) {
    on<BreathingPartLoad>(_onPartsLoaded);
  }
  Future<void> _onPartsLoaded(BreathingPartLoad event, Emitter emit) async {
    emit(BreathingLoading());
    try {
      final parts = await _breathsRepository.getParts();
      emit(PartsLoaded(parts));
    } on NetworkException catch (e) {
      emit(BreathingError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(BreathingError(e.message));
    } catch (e) {
      emit(BreathingError(e.toString()));
    }
  }
}
