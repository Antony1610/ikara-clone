import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/breaths/breaths_part.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

class BreathsRepositoryImpl implements BreathsRepository {
  final FirebaseService _service;
  BreathsRepositoryImpl(this._service);
  static const _tag = 'BreathsRepositoryImpl';
  @override
  Future<List<BreathsPart>> getParts() async {
    try {
      return await _service.getList(
        path: '$kdbBreaths/$kdbParts',
        fromJson: (json, id) => BreathsPart.fromJson(json, id),
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
      throw NetworkException('Lỗi khi tải danh sách phần', error: e);
    }
  }

  @override
  Future<BreathsPart> getDetailParts(String partId) async {
    try {
      final breath = await _service.getItem(
        path: '$kdbBreaths/$kdbParts/$partId',
        fromJson: (json, id) => BreathsPart.fromJson(json, id),
      );
      if (breath == null) {
        throw Exception('Không tìm thấy');
      }
      return breath;
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailParts',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getDetailParts',
        message: 'Unexpected error',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi tải danh sách phần', error: e);
    }
  }
}
