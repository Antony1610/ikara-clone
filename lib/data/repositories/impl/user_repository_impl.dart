import 'dart:io';

import 'package:ikara_clone/data/model/user/app_user.dart';
import 'package:ikara_clone/data/model/user/breath_user_result.dart';
import 'package:ikara_clone/data/model/user/lesson_user_result.dart';
import 'package:ikara_clone/data/model/user/practices_user_result.dart';
import 'package:ikara_clone/data/model/user/rhythms_user_result.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/data/services/user_service.dart';
import 'package:ikara_clone/data/services/storage_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  UserRepositoryImpl(
    this._userService,
    this._storageService,
    this._firebaseService,
  );

  @override
  Future<AppUser?> getUser(String uid) async {
    final data = await _userService.fetchUser(uid);
    if (data == null) return null;
    return AppUser.fromJson(uid, data);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _userService.updateAtPath('users/${user.id}', user.toJson());
  }

  @override
  Future<String?> uploadAvatar(String uid, File image) async {
    return await _storageService.uploadAvatar(uid, image);
  }

  @override
  Future<LessonUserResult?> getUserLesson(
    String uid,
    LessonUserResult userResult,
  ) async {
    final results = await _firebaseService.getList(
      path: '$kdbUsers/$uid/$kdbLessons/$kdbParts',
      fromJson: (json, partIndex) => LessonUserResult.fromJson(json, partIndex),
    );

    return results.cast<LessonUserResult?>().firstWhere(
      (r) => r?.id == userResult.id,
      orElse: () => null,
    );
  }

  @override
  Future<void> updateUserLesson(String uid, LessonUserResult result) async {
    final existing = await getUserLesson(uid, result);
    if (existing != null && result.process <= existing.process) return;

    if (existing != null) {
      final path = '$kdbUsers/$uid/$kdbLessons/$kdbParts/${existing.partIndex}';
      await _firebaseService.saveResult(
        path: path,
        result: result,
        toJson: (r) => r.toJson(),
      );
    } else {
      final results = await _firebaseService.getList(
        path: '$kdbUsers/$uid/$kdbLessons/$kdbParts',
        fromJson: (json, partIndex) =>
            LessonUserResult.fromJson(json, partIndex),
      );
      final newIndex = results.length;
      final path = '$kdbUsers/$uid/$kdbLessons/$kdbParts/$newIndex';
      await _firebaseService.saveResult(
        path: path,
        result: result,
        toJson: (r) => r.toJson(),
      );
    }
  }

  @override
  Future<List<LessonUserResult>> getListLessonResult(String uid) async {
    final results = await _firebaseService.getList(
      path: '$kdbUsers/$uid/$kdbLessons/$kdbParts',
      fromJson: (json, partIndex) => LessonUserResult.fromJson(json, partIndex),
    );
    return results;
  }

  @override
  Future<List<RhythmsUserResult>> getListRhythmsResult(String uid) async {
    final results = await _firebaseService.getList(
      path: '$kdbUsers/$uid/$kdbRhythms/$kdbParts',
      fromJson: (json, partIndex) =>
          RhythmsUserResult.fromJson(json, partIndex),
    );
    return results;
  }

  @override
  Future<RhythmsUserResult?> getUserRhythms(
    String uid,
    RhythmsUserResult userResult,
  ) async {
    final results = await getListRhythmsResult(uid);
    return results.cast<RhythmsUserResult?>().firstWhere((r) => r?.id == userResult.id, orElse: () => null);
  }

  @override
  Future<void> updateUserRhythms(
    String uid,
    RhythmsUserResult userResult,
  ) async {
    final existing = await getUserRhythms(uid, userResult);
    if (existing != null && userResult.score <= existing.score) return;
    if (existing != null) {
      final path = '$kdbUsers/$uid/$kdbRhythms/$kdbParts/${existing.indexId}';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    } else {
      final results = await getListRhythmsResult(uid);
      final newIndex = results.length;
      final path = '$kdbUsers/$uid/$kdbRhythms/$kdbParts/$newIndex';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    }
  }

  @override
  Future<List<BreathUserResult>> getListBreathsResult(String uid) async {
    final results = await _firebaseService.getList(
      path: '$kdbUsers/$uid/$kdbBreaths/$kdbParts',
      fromJson: (json, indexId) => BreathUserResult.fromJson(json, indexId),
    );
    return results;
  }

  @override
  Future<BreathUserResult?> getUserBreath(
    String uid,
    BreathUserResult userResult,
  ) async {
    final result = await getListBreathsResult(uid);
    return result.cast<BreathUserResult?>().firstWhere((r) => r?.id == userResult.id, orElse: () => null);
  }

  @override
  Future<void> updateUserBreaths(
    String uid,
    BreathUserResult userResult,
  ) async {
    final existing = await getUserBreath(uid, userResult);
    if (existing != null && userResult.score <= existing.score) return;
    if (existing != null) {
      final path = '$kdbUsers/$uid/$kdbBreaths/$kdbParts/${existing.indexId}';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    } else {
      final results = await getListBreathsResult(uid);
      final newIndex = results.length;
      final path = '$kdbUsers/$uid/$kdbBreaths/$kdbParts/$newIndex';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    }
  }

  @override
  Future<List<PracticesUserResult>> getListPracticesResult(String uid) async {
    final result = await _firebaseService.getList(
      path: '$kdbUsers/$uid/$kdbPractices/$kdbParts',
      fromJson: (json, indexId) => PracticesUserResult.fromJson(json, indexId),
    );
    return result;
  }

  @override
  Future<PracticesUserResult?> getUserPractices(
      String uid,
      PracticesUserResult userResult,
      ) async {
    final results = await getListPracticesResult(uid);

    return results.cast<PracticesUserResult?>().firstWhere(
          (r) => r?.id == userResult.id,
      orElse: () => null,
    );
  }

  @override
  Future<void> updateUserPractices(
    String uid,
    PracticesUserResult userResult,
  ) async {
    final existing = await getUserPractices(uid, userResult);
    if (existing != null && userResult.score <= existing.score) return;
    if (existing != null) {
      final path = '$kdbUsers/$uid/$kdbPractices/$kdbParts/${existing.indexId}';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    } else {
      final results = await getListPracticesResult(uid);
      final newIndex = results.length;
      final path = '$kdbUsers/$uid/$kdbPractices/$kdbParts/$newIndex';
      await _firebaseService.saveResult(
        path: path,
        result: userResult,
        toJson: (r) => r.toJson(),
      );
    }
  }
}
