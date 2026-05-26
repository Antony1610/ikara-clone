import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';

import '../../../constants/constants.dart';

part 'practices_event.dart';
part 'practices_state.dart';

class PracticesBloc extends Bloc<PracticesEvent, PracticesState>{
  final PracticesRepository _practicesRepository;
  final String uid;
  final UserRepository _userRepository;
  PracticesBloc(this._practicesRepository, this.uid, this._userRepository) : super(PracticesInitial()){
    on<PracticesLoad>(_onPracticesLoad);
  }

  Future<void> _onPracticesLoad(PracticesLoad event, Emitter emit) async {
    emit(PracticesLoading());
    try{
      final parts = await _practicesRepository.getListPractices();
      final userResult = await _userRepository.getListPracticesResult(uid);
      final scoreMap = {for (final r in userResult) r.id: r.score};
      emit(PracticesLoaded(parts, {
        for (final part in parts) part.id: _calcStar(scoreMap[part.id] ?? 0)
      }));
    } on NetworkException catch (e) {
      emit(PracticesError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(PracticesError(e.message));
    } catch (e) {
      emit(PracticesError(e.toString()));
    }
  }

  int _calcStar(int score) {
    if (score >= 80) return 3;
    if (score >= 50) return 2;
    if (score >= 20) return 1;
    return 0;
  }
}