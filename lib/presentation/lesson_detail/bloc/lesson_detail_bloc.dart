import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/constants/constants.dart';

part 'lesson_detail_state.dart';
part 'lesson_detail_event.dart';

class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final LessonsRepository _lessonsRepository;

  LessonDetailBloc(this._lessonsRepository)
      : super(LessonDetailInitial()) {
    on<LoadLessonDetail>(_onLoadLessonDetail);
    on<VideoPlayPauseToggled>(_onVideoPlayPauseToggled);
    on<VideoPositionChanged>(_onVideoPositionChanged);
    on<QuizSheetOpened>(_onQuizSheetOpened);
    on<QuizSheetClosed>(_onQuizSheetClose);
  }


  Future<void> _onLoadLessonDetail(
      LoadLessonDetail event,
      Emitter emit,
      ) async {
    emit(LessonDetailLoading());

    try {
      final selectedLesson = await _lessonsRepository.getDetailLesson(
        event.partId,
        event.lessonId,
      );

      final questions = await _lessonsRepository.getQuestion(
        event.partId,
        event.lessonId,
      );

      emit(
        LessonDetailLoaded(
          partId: event.partId,
          lesson: selectedLesson,
          questions: questions,
          isVideoPlaying: false,
          currentPosition: Duration.zero,
        ),
      );
    } on AppException catch (e) {
      emit(LessonDetailError(e.message));
    } catch (e) {
      emit(LessonDetailError(e.toString()));
    }
  }


  void _onVideoPlayPauseToggled(
      VideoPlayPauseToggled event,
      Emitter emit,
      ) {
    final current = state;
    if (current is! LessonDetailLoaded) return;

    emit(
      current.copyWith(
        isVideoPlaying: !current.isVideoPlaying,
      ),
    );
  }


  void _onVideoPositionChanged(
      VideoPositionChanged event,
      Emitter emit,
      ) {
    final current = state;
    if (current is! LessonDetailLoaded) return;

    if ((event.position - current.currentPosition).inMilliseconds.abs() < 50) {
      return;
    }

    emit(
      current.copyWith(
        currentPosition: event.position,
      ),
    );
  }

  void _onQuizSheetOpened(QuizSheetOpened event, Emitter emit) {
    final currentState = state;
    if (currentState is! LessonDetailLoaded) return;
    emit(currentState.copyWith(isSheetOpen: true));
  }

  void _onQuizSheetClose(QuizSheetClosed event, Emitter emit) {
    final currentState = state;
    if (currentState is! LessonDetailLoaded) return;
    emit(currentState.copyWith(isSheetOpen: false));
  }
}