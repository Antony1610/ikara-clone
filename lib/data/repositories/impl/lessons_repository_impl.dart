import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final FirebaseService _service;

  static const _tag = 'LessonsRepositoryImpl';

  LessonsRepositoryImpl(this._service);

  @override
  Future<List<Part>> getParts() async {
    try {
      return await _service.getList(
        path: '$kdbLessons/$kdbParts',
        fromJson: (json, id) => Part.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getParts',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getParts',
        message: 'Unexpected error',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy danh sách phần', error: e);
    }
  }

  @override
  Future<List<Lesson>> getLesson(String partId) async {
    try {
      final lessons = await _service.getList(
        path: '$kdbLessons/$kdbParts/$partId/$kdbLessons',
        fromJson: (json, id) => Lesson.fromJson(json, id),
      );

      if (lessons.isEmpty) {
        throw NotFoundException('Không tìm thấy bài học cho phần: $partId');
      }

      return lessons;
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getLesson',
        message: 'AppException (partId=$partId)',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getLesson',
        message: 'Unexpected error (partId=$partId)',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy danh sách bài học', error: e);
    }
  }

  @override
  Future<List<Question>> getQuestion(
    String partId,
    String lessonChildId,
  ) async {
    try {
      final questions = await _service.getList(
        path:
            '$kdbLessons/$kdbParts/$partId/$kdbLessons/$lessonChildId/$kdbQuestions',
        fromJson: (json, id) => Question.fromJson(json, id),
      );

      if (questions.isEmpty) {
        throw NotFoundException(
          'Không tìm thấy câu hỏi cho bài: $lessonChildId',
        );
      }

      return questions;
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getQuestion',
        message: 'AppException (partId=$partId, lessonChildId=$lessonChildId)',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getQuestion',
        message:
            'Unexpected error (partId=$partId, lessonChildId=$lessonChildId)',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy danh sách câu hỏi', error: e);
    }
  }

  @override
  Future<Lesson> getDetailLesson(String partId, String lessonChildId) async {
    try {
      final lesson = await _service.getItem(
        path: '$kdbLessons/$kdbParts/$partId/$kdbLessons/$lessonChildId',
        fromJson: (json, id) => Lesson.fromJson(json, id),
      );

      if (lesson == null) {
        throw NotFoundException(
          'Không tìm thấy thông tin cho bài học: $lessonChildId của phần $partId',
        );
      }

      return lesson;
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailLesson',
        message: 'AppException (partId=$partId, lessonChildId=$lessonChildId)',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailLesson',
        message:
            'Unexpected error (partId=$partId, lessonChildId=$lessonChildId)',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy thông tin bài học', error: e);
    }
  }
}
