import 'package:ikara_clone/constants/app_exception.dart';
import 'package:ikara_clone/constants/app_logger.dart';
import 'package:ikara_clone/data/model/rhythms/rhythms_part.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/resources/firestore/api_endpoint.dart';

class RhythmsRepositoryImpl implements RhythmsRepository {
  final FirebaseService _service;
  static const _tag = 'RhythmsRepositoryImpl';
  RhythmsRepositoryImpl(this._service);
  @override
  Future<RhythmsPart?> getRhythmsById(String indexId) async {
    try {
      return await _service.getItem(
        path: '$kdbRhythms/$kdbParts/$indexId',
        fromJson: (json, id) => RhythmsPart.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getRhythmsById',
        message: 'AppException (id: $indexId)',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getRhythmsById',
        message: 'Unexpected error (id: $indexId)',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy thông tin bài luyện nhịp', error: e);
    }
  }

  @override
  Future<List<RhythmsPart>> getRhythmsList() async {
    try {
      return await _service.getList(
        path: '$kdbRhythms/$kdbParts',
        fromJson: (json, id) => RhythmsPart.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getRhythmsById',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getRhythmsById',
        message: 'Unexpected error',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy thông tin bài luyện nhịp', error: e);
    }
  }
}
