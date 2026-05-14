import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
part 'lesson_event.dart';
part 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonsRepository _lessonsRepository;
  LessonBloc(this._lessonsRepository) : super(LessonInitial()) {
    on<LoadParts>(_onLoadParts);
    on<LoadLessons>(_onLoadLessons);
    on<LessonPageIndexChanged>(_onIndexChanged);
    on<LessonSelected>(_onLessonSelected);
    on<LessonCompleted>(_onLessonCompleted);
  }

  Future<void> _onLoadParts(LoadParts event, Emitter<LessonState> emit) async {
    emit(LessonLoading());

    try {
      final parts = await _lessonsRepository.getParts();

      emit(PartsLoaded(parts: parts));
    } on NetworkException catch (e) {
      emit(LessonError('Lỗi mạng: ${e.message}'));
    } on AppException catch (e) {
      emit(LessonError(e.message));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }

  Future<void> _onLoadLessons(
    LoadLessons event,
    Emitter<LessonState> emit,
  ) async {
    // Giữ lại parts để có thể back về
    final current = state;
    if (current is! PartsLoaded) return;

    emit(LessonLoading());

    try {
      final lessons = await _lessonsRepository.getLesson(event.partId);

      final selectedPart = current.parts.firstWhere(
        (p) => p.id == event.partId,
      );
      emit(LessonLoaded(selectedPart: selectedPart, lessons: lessons));
    } on AppException catch (e) {
      emit(LessonError(e.message));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }

  void _onIndexChanged(
    LessonPageIndexChanged event,
    Emitter<LessonState> emit,
  ) {
    final current = state;

    if (current is PartsLoaded) {
      emit(current.copyWith(currentIndex: event.index));
    } else if (current is LessonLoaded) {
      emit(current.copyWith(currentIndex: event.index));
    }
  }

  void _onLessonSelected(LessonSelected event, Emitter<LessonState> emit) {}

  void _onLessonCompleted(LessonCompleted event, Emitter<LessonState> emit) {
    final current = state;
    if (current is! LessonLoaded) return;

    final updated = Set<String>.from(current.completedLessonId)
      ..add(event.lessonId);

    emit(current.copyWith(completedLessonId: updated));
  }
}
