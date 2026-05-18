import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/data/model/lessons/question_result.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/model/user/lesson_user_result.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'lesson_question_event.dart';
part 'lesson_question_state.dart';

class LessonQuestionBloc
    extends Bloc<LessonQuestionEvent, LessonQuestionState> {
  final LessonsRepository _lessonsRepository;
  final UserRepository _userRepository;
  final String uid;

  LessonQuestionBloc(this._lessonsRepository, this._userRepository, this.uid)
    : super(LessonQuestionInitial()) {
    on<LoadLessonQuestion>(_onLoadLessonQuestion);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<SubmitQuiz>(_onSubmitQuiz);
  }

  Future<void> _onLoadLessonQuestion(
    LoadLessonQuestion event,
    Emitter emit,
  ) async {
    emit(LessonQuestionLoading());
    try {
      final questions = await _lessonsRepository.getQuestion(
        event.partId,
        event.lessonId,
      );
      emit(
        LessonQuestionLoaded(
          lessonId: event.lessonId,
          lessonTitle: event.title,
          lessonRealId: event.lessonRealId,
          questions: questions,
          userAnswer: List.filled(questions.length, null),
          currentIndex: 0,
          isCompleted: false,
          score: 0,
          questionResult: const [],
          lessonResult: null,
        ),
      );
    } on AppException catch (e) {
      emit(LessonQuestionError(e.message));
    } catch (e) {
      emit(LessonQuestionError(e.toString()));
    }
  }

  void _onSelectAnswer(SelectAnswer event, Emitter emit) {
    try {
      final currentState = state;
      if (currentState is! LessonQuestionLoaded) return;
      final updatedAnswers = List<int?>.from(currentState.userAnswer);
      updatedAnswers[currentState.currentIndex] = event.answerIndex;
      emit(currentState.copyWith(userAnswer: updatedAnswers));
    } on AppException catch (e) {
      emit(LessonQuestionError(e.message));
    } catch (e) {
      emit(LessonQuestionError(e.toString()));
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter emit) {
    try {
      final currentState = state;
      if (currentState is! LessonQuestionLoaded) return;
      final answeredCount = currentState.currentIndex + 1;
      final total = currentState.questions.length;
      final process = ((answeredCount / total) * 100).round();
      _userRepository.updateUserLesson(
        uid,
        LessonUserResult(
          id: currentState.lessonRealId,
          process: process,
          status: "LOCKED",
        ),
      );
      if (currentState.currentIndex < currentState.questions.length - 1) {
        emit(
          currentState.copyWith(currentIndex: currentState.currentIndex + 1),
        );
      }
    } on AppException catch (e) {
      emit(LessonQuestionError(e.message));
    } catch (e) {
      emit(LessonQuestionError(e.toString()));
    }
  }

  Future<void> _onSubmitQuiz(SubmitQuiz event, Emitter emit) async {
    try {
      final currentState = state;
      if (currentState is! LessonQuestionLoaded) return;

      int correct = 0;
      final questionResults = List.generate(currentState.questions.length, (i) {
        final q = currentState.questions[i];
        final selectedIdx = currentState.userAnswer[i];
        final selectedAnswer = selectedIdx != null
            ? q.options[selectedIdx]
            : '';
        final isCorrect = selectedAnswer == q.correctAnswer;
        if (isCorrect) correct++;
        return QuestionResult(
          question: q,
          selectedAnswer: selectedAnswer,
          isCorrect: isCorrect,
        );
      });

      final score = ((correct / currentState.questions.length) * 100).round();

      final lessonResult = LessonResult(
        lessonId: currentState.lessonId,
        lessonTitle: currentState.lessonTitle,
        totalQuestion: currentState.questions.length,
        correctCount: correct,
        questionResults: questionResults,
      );
      await _userRepository.updateUserLesson(
        uid,
        LessonUserResult(
          id: currentState.lessonRealId,
          process: 100,
          status: 'READY',
        ),
      );
      emit(
        currentState.copyWith(
          isCompleted: true,
          score: score,
          questionResult: questionResults,
          lessonResult: lessonResult,
        ),
      );
    } on AppException catch (e) {
      emit(LessonQuestionError(e.message));
    } catch (e) {
      emit(LessonQuestionError(e.toString()));
    }
  }
}
