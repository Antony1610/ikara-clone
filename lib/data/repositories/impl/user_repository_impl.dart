import 'dart:io';

import 'package:ikara_clone/data/model/user/app_user.dart';
import 'package:ikara_clone/data/model/user/lesson_user_result.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/data/services/firebase_service.dart';
import 'package:ikara_clone/data/services/user_service.dart';
import 'package:ikara_clone/data/services/storage_service.dart';
import 'package:ikara_clone/resources/firestore/firestore_resources.dart';

class UserRepositoryImpl implements UserRepository{

  final UserService _userService;
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  UserRepositoryImpl(this._userService, this._storageService, this._firebaseService);
  @override
  Future<AppUser?> getUser(String uid) async {
    final data = await _userService.fetchUser(uid);
    if (data == null) return null;
    return AppUser.fromJson(uid, data);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _userService.updateAtPath('users/$user.id', user.toJson());
  }

  @override
  Future<String?> uploadAvatar(String uid, File image) async {
    return await _storageService.uploadAvatar(uid, image);
  }

  @override
  Future<LessonUserResult?> getUserLesson(String uid, LessonUserResult userResult) async {
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
        path: path, result: result, toJson: (r) => r.toJson(),
      );
    } else {
      final results = await _firebaseService.getList(
        path: '$kdbUsers/$uid/$kdbLessons/$kdbParts',
        fromJson: (json, partIndex) => LessonUserResult.fromJson(json, partIndex),
      );
      final newIndex = results.length;
      final path = '$kdbUsers/$uid/$kdbLessons/$kdbParts/$newIndex';
      await _firebaseService.saveResult(
        path: path, result: result, toJson: (r) => r.toJson(),
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


}