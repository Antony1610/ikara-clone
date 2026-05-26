import 'dart:io';

// import 'package:ikara_clone/data/model/user/lesson_user_result.dart';


import 'package:ikara_clone/data/model/user/breath_user_result.dart';
import 'package:ikara_clone/data/model/user/practices_user_result.dart';
import 'package:ikara_clone/data/model/user/rhythms_user_result.dart';

import '../model/user/app_user.dart';
import '../model/user/lesson_user_result.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Future<void> updateUser(AppUser user);
  Future<String?> uploadAvatar(String uid, File image);
  Future<void> updateUserLesson(String uid, LessonUserResult result);
  Future<LessonUserResult?> getUserLesson(String uid, LessonUserResult userResult);
  Future<List<LessonUserResult>> getListLessonResult(String uid);
  Future<RhythmsUserResult?> getUserRhythms(String uid, RhythmsUserResult userResult);
  Future<List<RhythmsUserResult>> getListRhythmsResult(String uid);
  Future<void> updateUserRhythms(String uid, RhythmsUserResult userResult);
  Future<BreathUserResult?> getUserBreath(String uid, BreathUserResult userResult);
  Future<List<BreathUserResult>> getListBreathsResult(String uid);
  Future<void> updateUserBreaths(String uid, BreathUserResult userResult);
  Future<PracticesUserResult?> getUserPractices(String uid, PracticesUserResult userResult);
  Future<List<PracticesUserResult>> getListPracticesResult(String uid);
  Future<void> updateUserPractices(String uid, PracticesUserResult userResult);
}