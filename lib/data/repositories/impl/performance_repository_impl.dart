import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/performances/performance_lesson.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

class PerformanceRepositoryImpl implements PerformanceRepository {
  final FirebaseService _service;

  static const _tag = 'PerformanceRepositoryImpl';

  PerformanceRepositoryImpl(this._service);

  @override
  Future<PerformanceLesson> getDetailPerformance(String id) async {
    try {
      final performanceLesson = await _service.getItem(
        path: '$kdbPerformances/$kdbPerformanceLessons/$id',
        fromJson: (json, id) => PerformanceLesson.fromJson(json, id),
      );

      if (performanceLesson == null) {
        throw NotFoundException('Không tìm thấy bài trình diễn có id là: $id');
      }

      return performanceLesson;
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailPerformance',
        message: 'AppException (performanceId: $id)',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailPerformance',
        message: 'Unexpected error (performanceId: $id)',
        error: e,
        stackTrace: st,
      );

      throw NetworkException('Lỗi khi lấy thông tin bài trình diễn', error: e);
    }
  }

  @override
  Future<List<PerformanceLesson>> getListPerformance() async {
    try {
      return await _service.getList(
        path: '$kdbPerformances/$kdbPerformanceLessons',
        fromJson: (json, id) => PerformanceLesson.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getListPerformance',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getListPerformance',
        message: 'Unexpected error',
        error: e,
        stackTrace: st,
      );

      throw NetworkException(
        'Lỗi khi lấy danh sách các bài trình diễn',
        error: e,
      );
    }
  }
}
