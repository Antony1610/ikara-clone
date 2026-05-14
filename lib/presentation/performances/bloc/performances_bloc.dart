import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
part 'performances_event.dart';
part 'performances_state.dart';

class PerformancesBloc extends Bloc<PerformancesEvent, PerformancesState> {
  final PerformanceRepository _performanceRepository;
  PerformancesBloc(this._performanceRepository) : super(PerformancesInitial()) {
    on<LoadPerformances>(_onLoadPerformances);
  }

  Future<void> _onLoadPerformances(LoadPerformances event, Emitter emit) async {
    emit(PerformancesLoading());
    try {
      final performances = await _performanceRepository.getListPerformance();
      emit(PerformancesLoaded(performances));
    } on NetworkException catch (e) {
      emit(PerformancesError(e.message));
    } on AppException catch (e) {
      emit(PerformancesError(e.message));
    } catch (e) {
      emit(PerformancesError(e.toString()));
    }
  }
}
