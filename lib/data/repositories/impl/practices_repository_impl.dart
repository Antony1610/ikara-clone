import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/practices/practices_part.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

import '../../karaoke/midi_parse.dart';
import '../../model/practices/midi_note_practices.dart';

class PracticesRepositoryImpl implements PracticesRepository {
  final FirebaseService _service;
  final _midiParse = MidiParse();

  static const _tag = 'PracticesRepositoryImpl';
  PracticesRepositoryImpl(this._service);

  @override
  Future<List<PracticesPart>> getListPractices() async {
    try {
      return await _service.getList(
        path: '$kdbPractices/$kdbParts',
        fromJson: (json, id) => PracticesPart.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getListPractices',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getListPractices',
        message: 'Unexpected error',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy thông tin bài luyện thanh');
    }
  }

  @override
  Future<PracticesPart?> getPractices(String id) async {
    try {
      return await _service.getItem(
        path: '$kdbPractices/$kdbParts/$id',
        fromJson: (json, id) => PracticesPart.fromJson(json, id),
      );
    } on AppException catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getPractices',
        message: 'AppException',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      AppLogger.logError(
        tag: '$_tag.getPractices',
        message: 'Unexpected error (id: $id)',
        error: e,
        stackTrace: st,
      );
      throw NetworkException('Lỗi khi lấy thông tin chi tiết bài luyện thanh');
    }
  }
  @override
  Future<List<MidiNotePractices>> getMidiNotes(String midiPath) {
    return _midiParse.parseFromPathAsync(midiPath);
  }
}
