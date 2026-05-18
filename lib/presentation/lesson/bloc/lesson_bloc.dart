import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/user/lesson_user_result.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'lesson_event.dart';
part 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonsRepository _lessonsRepository;
  final UserRepository _userRepository;
  final String uid;
  LessonBloc(this._lessonsRepository, this._userRepository, this.uid) : super(LessonInitial()) {
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
      final userResult = await _userRepository.getListLessonResult(uid);
      int currentIndex = 0;
      int globalIndex = 0;
      bool found = false;
      for (final part in parts) {
        for (final lesson in part.lessons){
          if (!found) {
            try {
              final result = userResult.firstWhere((r) => r.id == lesson.id);
              if (result.process < 100) {
                currentIndex = globalIndex;
                found = true;
              }
            } catch (_) {
              currentIndex = globalIndex;
              found = true;
            }
          }
          globalIndex++;
        }
      }
      emit(PartsLoaded(parts: parts, userResults: userResult, currentIndex: currentIndex));
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
    final current = state;
    if (current is! PartsLoaded) return;

    emit(LessonLoading());

    try {

      final selectedPart = current.parts.firstWhere(
        (p) => p.id == event.partId,
      );
      emit(LessonLoaded(selectedPart: selectedPart, lessons: selectedPart.lessons));
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
