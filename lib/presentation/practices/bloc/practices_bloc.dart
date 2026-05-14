import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';

import '../../../constants/constants.dart';

part 'practices_event.dart';
part 'practices_state.dart';

class PracticesBloc extends Bloc<PracticesEvent, PracticesState>{
  final PracticesRepository _practicesRepository;
  PracticesBloc(this._practicesRepository) : super(PracticesInitial()){
    on<PracticesLoad>(_onPracticesLoad);
  }

  Future<void> _onPracticesLoad(PracticesLoad event, Emitter emit) async {
    emit(PracticesLoading());
    try{
      final parts = await _practicesRepository.getListPractices();
      emit(PracticesLoaded(parts));
    } on NetworkException catch (e) {
      emit(PracticesError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(PracticesError(e.message));
    } catch (e) {
      emit(PracticesError(e.toString()));
    }
  }
}